import sys
import csv
from lxml import etree

working_dir = sys.argv[1]
coord_file = sys.argv[2]
xml_input = sys.argv[3]

coords = []
with open(coord_file) as _file:
    reader = csv.DictReader(_file)
    for i in reader:
        coords.append(i)

def create_dict(input_list, key, value):
    output_dict = {}
    for i in input_list:
        output_dict[i[key]] = i[value]
    return output_dict

# Sort coord data into dicts
dxs = create_dict(coords, "fov", "dxM")
dys = create_dict(coords, "fov", "dyM")

xml_doc = etree.parse(xml_input)

enable = etree.parse(working_dir+'enable.xsl')

t_enable = etree.XSLT(enable)

# Disable all fields.
for wellx in range(12):
    for welly in range(8):
        for fieldx in range(4): # 4x4 fields (all)
            for fieldy in range(4):
                # Testing
                print(wellx+" "+welly+" "+fieldx+" "+fieldy+)
                xml_doc = t_enable(xml_doc, WELLX=str(wellx+1),
                            WELLY=str(welly+1), FIELDX=str(fieldx+1),
                            FIELDY=str(fieldy+1), ENABLE="'false'")

# For each fov in dxs, enable and change x/y coordinates
for k, v in dxs.iteritems():
    # change xcoord in well k
    wellx = str(int(k[1:3])+1)
    welly = str(int(k[6:8])+1)
    fieldx = str(int(k[11:13])+1)
    fieldy = str(int(k[16:18])+1)
    dx = v
    dy = dys[k]
    # Testing
    print(wellx+" "+welly+" "+fieldx+" "+fieldy+" "+dx+" "+dy)
    xml_doc = t_enable(xml_doc, WELLX=wellx, WELLY=welly, FIELDX=fieldx,
            FIELDY=fieldy, ENABLE="'true'", DRIFT="'true'", DX=str(dx),
            DY=str(dy))

# Save the xml to file
xml_doc.write(xml_input[0:-4]+'_new.xml', pretty_print=False)
