#!/usr/bin/env python3
"""Inspect, encode, compare, and simulate Factorio blueprint artifacts."""

import argparse
import base64
import collections
import json
import re
import shutil
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path


def load(path):
    text = Path(path).read_text(encoding='utf-8').strip()
    if text.startswith('0'):
        text = zlib.decompress(base64.b64decode(text[1:], validate=True)).decode()
    obj = json.loads(text)
    validate(obj)
    return obj


def validate(obj):
    if 'blueprint_book' in obj:
        book = obj['blueprint_book']
        if book.get('item') != 'blueprint-book' or not book.get('blueprints'):
            raise ValueError('Invalid or empty blueprint book')
        indexes = [entry['index'] for entry in book['blueprints']]
        if len(indexes) != len(set(indexes)):
            raise ValueError('Duplicate blueprint book indexes')
        for entry in book['blueprints']:
            validate({key: value for key, value in entry.items() if key != 'index'})
        return
    bp = obj.get('blueprint')
    if not isinstance(bp, dict) or bp.get('item') != 'blueprint':
        raise ValueError('Expected a wrapped blueprint or blueprint_book object')
    entities = bp.get('entities', [])
    ids = [e['entity_number'] for e in entities]
    if len(ids) != len(set(ids)) or any(not isinstance(n, int) or n <= 0 for n in ids):
        raise ValueError('Entity numbers must be unique positive integers')
    positions = set()
    for e in entities:
        p = e['position']
        if not e.get('name') or not all(isinstance(p[k], (int, float)) for k in ('x', 'y')):
            raise ValueError('Invalid entity name or position')
        signature = (e['name'], p['x'], p['y'])
        if signature in positions:
            raise ValueError(f'Duplicate entity: {signature}')
        positions.add(signature)
    for edge in bp.get('wires', []):
        if len(edge) != 4 or edge[0] not in ids or edge[2] not in ids:
            raise ValueError(f'Invalid wire reference: {edge}')


def encode(obj):
    validate(obj)
    raw = json.dumps(obj, separators=(',', ':'), ensure_ascii=False).encode()
    code = '0' + base64.b64encode(zlib.compress(raw, 9)).decode()
    assert json.loads(zlib.decompress(base64.b64decode(code[1:]))) == obj
    return code


def blueprints(obj):
    if 'blueprint' in obj:
        return [obj['blueprint']]
    result = []
    for entry in obj['blueprint_book']['blueprints']:
        result.extend(blueprints(entry))
    return result


def summary(obj):
    return [{'label': bp.get('label'), 'version': bp.get('version'),
             'entities': dict(collections.Counter(e['name'] for e in bp.get('entities', []))),
             'copper_or_circuit_wires': len(bp.get('wires', [])),
             'recipes': sorted({e['recipe'] for e in bp.get('entities', []) if 'recipe' in e})}
            for bp in blueprints(obj)]


def compare(a, b):
    if len(blueprints(a)) != 1 or len(blueprints(b)) != 1:
        raise ValueError('Compare standalone blueprints, not books')
    a, b = blueprints(a)[0], blueprints(b)[0]
    def position(e):
        return e['name'], e['position']['x'], e['position']['y']
    def normalized(e):
        return {k: v for k, v in e.items() if k != 'entity_number'}
    target = {position(e): e for e in b.get('entities', [])}
    missing, changed = [], []
    for e in a.get('entities', []):
        other = target.get(position(e))
        if other is None:
            missing.append(position(e))
        elif normalized(other) != normalized(e):
            changed.append({'position': position(e), 'before': normalized(e), 'after': normalized(other)})
    def wires(bp):
        identities = {e['entity_number']: position(e) for e in bp.get('entities', [])}
        return {tuple(sorted(((identities[u], cu), (identities[v], cv))))
                for u, cu, v, cv in bp.get('wires', [])}
    removed_wires = sorted(wires(a) - wires(b))
    old_positions = {position(e) for e in a.get('entities', [])}
    additions = [normalized(e) for e in b.get('entities', []) if position(e) not in old_positions]
    return {'preserves_starter': not (missing or changed or removed_wires),
            'missing': missing, 'changed': changed, 'removed_wires': removed_wires,
            'additions': additions}


def installation(args):
    user = Path(args.user_data).expanduser() if args.user_data else Path.home() / 'Library/Application Support/factorio'
    candidates = [Path(args.factorio).expanduser()] if args.factorio else [
        Path.home() / 'Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio',
        Path('/Applications/factorio.app/Contents/MacOS/factorio'),
        Path('/Applications/Factorio.app/Contents/MacOS/factorio')]
    binary = next((p.resolve() for p in candidates if p.is_file()), None)
    log = user / 'factorio-current.log'
    lines = log.read_text(errors='replace').splitlines() if log.exists() else []
    version = next((re.search(r'Factorio (\d+\.\d+\.\d+)', line).group(1)
                    for line in lines if re.search(r'Factorio (\d+\.\d+\.\d+)', line)), None)
    data = None
    for line in lines:
        if 'Read data path: ' in line:
            data = Path(line.split('Read data path: ', 1)[1].rsplit(' [', 1)[0])
            break
    if data is None and binary:
        data = binary.parent.parent / 'data'
    mods = user / 'mods'
    enabled_path = mods / 'mod-list.json'
    enabled = json.loads(enabled_path.read_text()) if enabled_path.exists() else {'mods': [{'name': 'base', 'enabled': True}]}
    loaded = [line.split('Loading mod ', 1)[1] for line in lines if 'Loading mod ' in line and '(data.lua)' in line]
    return {'factorio': str(binary) if binary else None, 'user_data': str(user),
            'read_data': str(data) if data else None, 'mods': str(mods),
            'game_version': version, 'enabled_mods': enabled, 'loaded_mods': loaded}


def lua(value):
    if value is None:
        return 'nil'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        return '{' + ','.join(lua(v) for v in value) + '}'
    return '{' + ','.join('[' + lua(k) + ']=' + lua(v) for k, v in value.items()) + '}'


def simulate(args):
    manifest_path = Path(args.input).resolve()
    manifest = json.loads(manifest_path.read_text())
    cases = manifest['cases']
    if not cases:
        raise ValueError('No simulation cases')
    for case in cases:
        obj = load(manifest_path.parent / case['blueprint'])
        if len(blueprints(obj)) != 1:
            raise ValueError('Each simulation case requires one standalone blueprint')
        case['code'] = encode(obj)
        case['blueprint_entities'] = blueprints(obj)[0]['entities']
        if not case['blueprint_entities'] or not case.get('outputs'):
            raise ValueError('Each case needs entities and output acceptance criteria')
        if case.get('warmup_ticks', 0) < 1 or case.get('sample_ticks', 0) < 60:
            raise ValueError('Use positive warmup ticks and at least 60 sample ticks')
    info = installation(args)
    if not info['factorio'] or not info['read_data']:
        raise ValueError('Cannot locate matching game; pass --factorio and --user-data')
    root = Path(tempfile.mkdtemp(prefix='factorio-blueprint-test-'))
    write = root / 'write'; write.mkdir()
    mods = root / 'mods'; mods.mkdir()
    source = Path(info['mods'])
    for entry in source.iterdir():
        if entry.suffix == '.zip' or (entry.is_dir() and (entry / 'info.json').exists()):
            (mods / entry.name).symlink_to(entry.resolve(), target_is_directory=entry.is_dir())
    settings = source / 'mod-settings.dat'
    if settings.exists():
        shutil.copyfile(settings, mods / settings.name)
    enabled = json.loads(json.dumps(info['enabled_mods']))
    validator = 'codex-blueprint-validator'
    if any(entry['name'] == validator for entry in enabled['mods']):
        raise ValueError('Temporary validator mod name already exists in the installed mod list')
    enabled['mods'].append({'name': validator, 'enabled': True})
    (mods / 'mod-list.json').write_text(json.dumps(enabled))
    mod = mods / (validator + '_0.1.0'); mod.mkdir()
    game_major_minor = '.'.join((info['game_version'] or manifest.get('game_version', '2.0')).split('.')[:2])
    (mod / 'info.json').write_text(json.dumps({'name': validator, 'version': '0.1.0',
        'title': 'Temporary blueprint validation', 'author': 'Codex',
        'factorio_version': game_major_minor, 'dependencies': ['base']}))
    (mod / 'cases.lua').write_text('return ' + lua(cases) + '\n')
    shutil.copyfile(Path(__file__).with_name('validator.lua'), mod / 'control.lua')
    config = root / 'config.ini'
    config.write_text('[path]\nread-data=' + info['read_data'] + '\nwrite-data=' + str(write) + '\n[general]\ncheck-updates=false\n')
    common = [info['factorio'], '--config', str(config), '--mod-directory', str(mods), '--disable-audio']
    end = max(c['warmup_ticks'] + c['sample_ticks'] for c in cases) + 1
    commands = [('create', ['--create', str(root / 'test.zip'), '--map-gen-seed', '1']),
                ('benchmark', ['--benchmark', str(root / 'test.zip'), '--benchmark-ticks', str(end)])]
    report = {'installation': info, 'sandbox': str(root), 'passed': False, 'results': []}
    report_path = Path(args.report).resolve()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    print('Isolated test directory: ' + str(root), flush=True)
    try:
        for label, tail in commands:
            print('Running ' + label, flush=True)
            with (root / (label + '.log')).open('w') as log:
                result = subprocess.run(common + tail, stdout=log, stderr=subprocess.STDOUT,
                                        timeout=args.timeout, check=False)
            if result.returncode:
                raise RuntimeError(f'{label} exited {result.returncode}; see {root / (label + ".log")}')
        events = write / 'script-output/blueprint-validation.jsonl'
        for line in events.read_text().splitlines():
            event = json.loads(line)
            if event['event'] == 'result':
                report['results'].append(event)
        if len(report['results']) != len(cases) or not all(r['passed'] for r in report['results']):
            raise RuntimeError('Missing or failing output measurements')
        report['passed'] = True
    except (RuntimeError, subprocess.TimeoutExpired, OSError) as error:
        report['error'] = str(error)
        raise
    finally:
        report_path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': True, 'report': str(report_path), 'results': report['results']}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    for command in ['pack', 'unpack']:
        p = sub.add_parser(command); p.add_argument('input'); p.add_argument('output')
    for command in ['summary', 'copy']:
        p = sub.add_parser(command); p.add_argument('input')
    p = sub.add_parser('compare'); p.add_argument('starter'); p.add_argument('expanded')
    for command in ['inspect', 'simulate']:
        p = sub.add_parser(command); p.add_argument('--factorio'); p.add_argument('--user-data')
        if command == 'simulate':
            p.add_argument('input'); p.add_argument('--report', required=True)
            p.add_argument('--timeout', type=int, default=90)
    args = parser.parse_args()
    if args.command == 'inspect':
        print(json.dumps(installation(args), indent=2))
    elif args.command in ['pack', 'unpack']:
        obj = load(args.input)
        output = encode(obj) if args.command == 'pack' else json.dumps(obj, indent=2)
        Path(args.output).write_text(output + '\n')
        print(args.output)
    elif args.command == 'summary':
        print(json.dumps(summary(load(args.input)), indent=2))
    elif args.command == 'compare':
        result = compare(load(args.starter), load(args.expanded))
        print(json.dumps(result, indent=2))
        if not result['preserves_starter']:
            raise SystemExit(1)
    elif args.command == 'copy':
        code = encode(load(args.input))
        subprocess.run(['pbcopy'], input=code.encode(), check=True)
        actual = subprocess.run(['pbpaste'], capture_output=True, check=True).stdout.decode()
        if actual != code:
            raise RuntimeError('Clipboard readback differs')
        print(f'Copied and verified {len(code)} characters')
    else:
        simulate(args)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, OSError, RuntimeError, zlib.error, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
