#!/usr/bin/env python3
"""Worked K2 example. Recheck recipe/port assumptions for other releases."""

import argparse
import importlib.util
import json
from pathlib import Path

module_path = Path(__file__).resolve().parents[1] / 'scripts/blueprint.py'
spec = importlib.util.spec_from_file_location('blueprint', module_path)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)


def make(count, version):
    entities = []
    def add(name, x, y, **extra):
        entities.append(dict(entity_number=len(entities)+1, name=name, position=dict(x=x,y=y), **extra))
    # Keep the first machine and all existing ports fixed between variants.
    for i in range(count):
        add('kr-greenhouse',3.5+10*i,3.5,recipe='wood')
    for i in range(count):
        x=3.5+10*i
        add('inserter',x,7.5,direction=0)
        add('wooden-chest',x,8.5,bar=2)
        add('pipe',x,-.5)
    for x in range(-2,int(3.5+10*(count-1))):
        add('pipe',x+.5,-1.5)
    add('pipe',3.5+10*(count-1),-1.5)
    poles=[]
    for i in range(count):
        for x,y in [(2.5+10*i,7.5),(7.5+10*i,6.5)]:
            add('small-electric-pole',x,y)
            poles.append(entities[-1]['entity_number'])
    wires=[[a,5,b,5] for a,b in zip(poles,poles[1:])]
    parts=[int(n) for n in version.split('.')]
    parts += [0]*(4-len(parts))
    packed=sum(n<<shift for n,shift in zip(parts,[48,32,16,0]))
    return {'blueprint':dict(item='blueprint',label=f'K2 wood - {count} greenhouses',
        description=f'{count} greenhouses, nominal {count*40} wood/min. WATER IN: leftmost pipe at top left. Connect any pole to your grid. Collect wood below each greenhouse. No coal or fertilizer required. To expand, keep the same rotation and align the leftmost greenhouse. Requires researched greenhouse and the standard water-only wood recipe. Tested version is recorded in the validation report.',
        entities=entities,wires=wires,version=packed,
        icons=[dict(index=1,signal=dict(type='item',name='kr-greenhouse')),
               dict(index=2,signal=dict(type='item',name='wood'))])}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',required=True)
    parser.add_argument('--game-version',required=True)
    args=parser.parse_args()
    out=Path(args.output).expanduser();out.mkdir(parents=True,exist_ok=True)
    variants=[];cases=[]
    for count in [2,4]:
        obj=make(count,args.game_version)
        name=f'{count}-greenhouses'
        (out/(name+'.json')).write_text(json.dumps(obj,indent=2)+'\n')
        (out/(name+'.txt')).write_text(helper.encode(obj)+'\n')
        variants.append(obj['blueprint'])
        cases.append(dict(name=name,blueprint=name+'.json',warmup_ticks=7200,sample_ticks=14400,
            power=dict(source=dict(x=-4,y=9),pole=dict(x=-1.5,y=8.5)),
            fluids=[dict(entity='pipe',position=dict(x=-1.5,y=-1.5),name='water',amount=100,every_ticks=1)],
            outputs=[dict(item='wood',entity='wooden-chest',minimum_per_minute=count*39)]))
    book={'blueprint_book':dict(item='blueprint-book',label='K2 extendible greenhouse row',
        description='2 greenhouse starter and compatible 4 greenhouse expansion. Water and electricity in; wood in individual chests.',
        active_index=0,version=variants[0]['version'],blueprints=[dict(index=i,blueprint=b) for i,b in enumerate(variants)])}
    (out/'blueprint-book.json').write_text(json.dumps(book,indent=2)+'\n')
    (out/'blueprint-book.txt').write_text(helper.encode(book)+'\n')
    (out/'cases.json').write_text(json.dumps(dict(game_version=args.game_version,cases=cases),indent=2)+'\n')
    (out/'footprints.json').write_text(json.dumps({'kr-greenhouse':[7,7],'pipe':[1,1],
        'small-electric-pole':[1,1],'wooden-chest':[1,1],'inserter':[1,1]},indent=2)+'\n')
    comparison=helper.compare({'blueprint':variants[0]},{'blueprint':variants[1]})
    assert comparison['preserves_starter'],comparison
    (out/'expansion-check.json').write_text(json.dumps(comparison,indent=2)+'\n')
    print(json.dumps(dict(output=str(out),materials=helper.summary(book)),indent=2))


if __name__=='__main__':main()
