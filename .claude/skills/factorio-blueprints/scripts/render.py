#!/usr/bin/env python3
"""Render a tile placement schematic from JSON and explicit footprint data. Requires Pillow."""

import argparse
import collections
import json
import math
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
from blueprint import load,blueprints


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input');parser.add_argument('footprints');parser.add_argument('output')
    args=parser.parse_args()
    values=blueprints(load(args.input))
    if len(values)!=1:raise ValueError('Render one standalone blueprint at a time')
    bp=values[0];sizes=json.loads(Path(args.footprints).read_text());entities=bp['entities']
    for e in entities:
        if e['name'] not in sizes:raise ValueError('Missing footprint: '+e['name'])
    left=min(e['position']['x']-sizes[e['name']][0]/2 for e in entities)-1
    right=max(e['position']['x']+sizes[e['name']][0]/2 for e in entities)+1
    top=min(e['position']['y']-sizes[e['name']][1]/2 for e in entities)-1
    bottom=max(e['position']['y']+sizes[e['name']][1]/2 for e in entities)+1
    cell=30; width=max(900,math.ceil((right-left)*cell)+80);height=math.ceil((bottom-top)*cell)+280
    im=Image.new('RGB',(width,height),'#111820');draw=ImageDraw.Draw(im)
    fontdir=Path('/System/Library/Fonts/Supplemental')
    def font(size,bold=False):
        path=fontdir/('Arial Bold.ttf' if bold else 'Arial.ttf')
        return ImageFont.truetype(str(path),size) if path.exists() else ImageFont.load_default(size=size)
    def text(p,s,size=16,color='#edf2f7',anchor=None,bold=False):draw.text(p,s,font=font(size,bold),fill=color,anchor=anchor)
    def sx(x):return 40+(x-left)*cell
    def sy(y):return 140+(y-top)*cell
    text((40,28),bp.get('label','Blueprint'),28,bold=True)
    text((40,70),'Tile placement schematic. Water and electricity in; collect output from the chests.',17,'#b2c1cd')
    for x in range(math.floor(left),math.ceil(right)+1):draw.line((sx(x),sy(top),sx(x),sy(bottom)),fill='#253340')
    for y in range(math.floor(top),math.ceil(bottom)+1):draw.line((sx(left),sy(y),sx(right),sy(y)),fill='#253340')
    ids={e['entity_number']:e for e in entities}
    for a,_,b,_ in bp.get('wires',[]):
        p,q=ids[a]['position'],ids[b]['position']
        draw.line((sx(p['x']),sy(p['y']),sx(q['x']),sy(q['y'])),fill='#9e764e',width=2)
    for e in entities:
        name=e['name'];x=sx(e['position']['x']);y=sy(e['position']['y']);w,h=sizes[name]
        if name=='small-electric-pole':draw.ellipse((x-6,y-6,x+6,y+6),fill='#17384c',outline='#74c4ef',width=2)
        elif name=='inserter':
            dx,dy={0:(0,1),4:(-1,0),8:(0,-1),12:(1,0)}[e.get('direction',0)]
            draw.line((x-dx*11,y-dy*11,x+dx*11,y+dy*11),fill='#f4c966',width=3)
            draw.polygon([(x+dx*12,y+dy*12),(x+dx*4-dy*5,y+dy*4+dx*5),(x+dx*4+dy*5,y+dy*4-dx*5)],fill='#f4c966')
        elif name=='pipe':draw.rounded_rectangle((x-8,y-8,x+8,y+8),3,fill='#275d76',outline='#72c4ea',width=2)
        elif name=='wooden-chest':draw.rounded_rectangle((x-12,y-12,x+12,y+12),3,fill='#a67c52',outline='#e7c799')
        else:
            draw.rounded_rectangle((x-w*cell/2+2,y-h*cell/2+2,x+w*cell/2-2,y+h*cell/2-2),9,fill='#24554b',outline='#57b69c',width=2)
            text((x,y-12),name.removeprefix('kr-').replace('-',' ').upper(),16,anchor='mm',bold=True)
            text((x,y+14),e.get('recipe',''),15,anchor='mm')
    text((sx(-1.5),sy(-1.5)-27),'WATER IN →',16)
    counts=collections.Counter(e['name'] for e in entities)
    bill=' | '.join(f'{n} {name.removeprefix("kr-").replace("-"," ")}' for name,n in counts.items())
    text((40,height-100),bill,15,'#b2c1cd')
    text((40,height-67),'Expansion: keep the same rotation and align the LEFTMOST greenhouse.',18)
    text((40,height-37),'Connect any pole to the factory grid. Supply water through the top-left pipe.',16,'#b2c1cd')
    im.save(args.output)
    print(args.output)


if __name__=='__main__':main()
