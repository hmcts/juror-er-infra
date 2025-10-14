import argparse
import os
import json

FOLDER = '/synapse/notebook/'


def execution_count_validator(elem, name):
    if 'execution_count' in elem.keys():
        if elem['execution_count'] is not None:
            return False
    return True

def read_file(root_path, folder,  _file):
    full_path = root_path + folder + _file
    with open(full_path, mode='r', encoding='utf-8-sig') as f1:
        content = f1.read()

    return content


def main():

    parser = argparse.ArgumentParser(description='Validate synapse notebooks.')
    parser.add_argument('root', help='folder root')
    args = parser.parse_args()
    root_path = args.root
    validators = [execution_count_validator]
    files = os.listdir(args.root + FOLDER)
    result = []
    allowed_list = []
    for _file in files:
        content = read_file(root_path, FOLDER, _file)
        try:
            json_content = json.loads(content)
        except:
            print(content)
        elems = json_content['properties']['cells']
        for validator in validators:
            found = False
            for elem in elems:
                val_result = validator(elem, json_content['name'])
                if (not val_result) & (validator.__name__ != 'param_cell_validator'):
                    result.append({validator.__name__: json_content['name']})
                    break
                elif (val_result) & (validator.__name__ == 'param_cell_validator'):
                    found = True
            if (validator.__name__ == 'param_cell_validator') & (not found) & (json_content['name'] not in allowed_list):
                result.append({validator.__name__: json_content['name']})
    print(*result, sep='\n')
    if result:
        raise Exception("Validation failed")


if __name__ == '__main__':
    main()
