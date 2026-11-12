import copy
import unittest
from blueprint import compare, encode, validate, blueprints
import base64
import zlib
import json


def fixture():
    return {'blueprint': {'item': 'blueprint', 'version': 2 << 48,
        'entities': [
            {'entity_number': 1, 'name': 'small-electric-pole', 'position': {'x': .5, 'y': .5}},
            {'entity_number': 2, 'name': 'small-electric-pole', 'position': {'x': 4.5, 'y': .5}},
            {'entity_number': 3, 'name': 'assembling-machine-1', 'position': {'x': 2.5, 'y': 3.5}, 'recipe': 'copper-cable'}],
        'wires': [[1, 5, 2, 5]]}}


class BlueprintTests(unittest.TestCase):
    def test_encoded_book_preserves_nested_unicode_labels(self):
        a=fixture();a['blueprint']['label']='Trær og strøm'
        book={'blueprint_book': {'item':'blueprint-book', 'blueprints':[{'index':0,**a}]}}
        code=encode(book)
        self.assertEqual(json.loads(zlib.decompress(base64.b64decode(code[1:]))),book)
        self.assertEqual(len(blueprints(book)),1)

    def test_dangling_wires_and_duplicate_entity_ids_are_rejected(self):
        a=fixture();a['blueprint']['wires'][0][2]=99
        with self.assertRaises(ValueError):validate(a)
        a=fixture();a['blueprint']['entities'][1]['entity_number']=1
        with self.assertRaises(ValueError):validate(a)

    def test_expansion_accepts_renumbering_but_preserves_physical_wires(self):
        a=fixture();b=copy.deepcopy(a)
        for e in b['blueprint']['entities']:e['entity_number']+=10
        b['blueprint']['wires']=[[12,5,11,5]]
        self.assertTrue(compare(a,b)['preserves_starter'])
        b['blueprint']['wires']=[]
        self.assertFalse(compare(a,b)['preserves_starter'])

    def test_recipe_change_is_not_a_preserving_expansion(self):
        a=fixture();b=copy.deepcopy(a)
        b['blueprint']['entities'][2]['recipe']='iron-gear-wheel'
        result=compare(a,b)
        self.assertFalse(result['preserves_starter'])
        self.assertEqual(len(result['changed']),1)


if __name__=='__main__':unittest.main()
