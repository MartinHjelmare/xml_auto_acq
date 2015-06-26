import sys
import csv
import numpy
from lxml import etree
import re

working_dir = sys.argv[1]
gain_file = sys.argv[2]
xml_input = sys.argv[3]
lrp_input = sys.argv[4]

gains = []
with open(gain_file) as _file:
    reader = csv.DictReader(_file)
    for i in reader:
        gains.append(i)

def create_dict(input_list, output_dict, key, value):
    for i in input_list:
        output_dict[i[key]] = i[value]
    return output_dict

# Sort gain data into one dict for each channel
green = {}
blue = {}
yellow = {}
red = {}
green = create_dict(gains, green, "well", "green")
blue = create_dict(gains, blue, "well", "blue")
yellow = create_dict(gains, yellow, "well", "yellow")
red = create_dict(gains, red, "well", "red")

# Round gain values to multiples of 10
def round_values(input_dict, output_list):
    for k, v in input_dict.iteritems():
        v = int(round(int(v), -1))
        input_dict[k] = v
        output_list.append(v)
    return

green_list = []
round_values(green, green_list)

# Find the unique set of green gain values for whole plate
green_unique = sorted(set(green_list))

# Find median gain for whole plate for marker channels
blue_list = []
round_values(blue, blue_list)
blue_median = int(numpy.median(blue_list))
yellow_list = []
round_values(yellow, yellow_list)
yellow_median = int(numpy.median(yellow_list))
red_list = []
round_values(red, red_list)
red_median = int(numpy.median(red_list))

xml_doc = etree.parse(xml_input)
lrp_doc = etree.parse(lrp_input)
get_val = etree.parse(working_dir+'getval.xsl')
copy_job = etree.parse(working_dir+'copy_job.xsl')
set_gain = etree.parse(working_dir+'gain_set.xsl')
enable = etree.parse(working_dir+'enable.xsl')

t_get_val = etree.XSLT(get_val)
t_copy_job = etree.XSLT(copy_job)
t_set_gain = etree.XSLT(set_gain)
t_enable = etree.XSLT(enable)

# For each pos in green_unique, copy job, change gain in channels,
# assign the job if value of green_unique matches any value in green

for green_val in green_unique:
    #testing
    print(green_val)

    #find last BlockID, ElementID and UserSettingName for last existing job
    #copy <LDM_Block_Sequence_Block n BlockID=str(n)> to
    # <LDM_Block_Sequence_Block n+i BlockID=str(n+i)>
    #copy <LDM_Block_Sequence_Element n BlockID=str(n) ElementID=str(p)> to
    # <LDM_Block_Sequence_Element n+i BlockID=str(n+i) ElementID=str(p+i)>
    #set gain for job n+i
    #green_detector = green_val
    #blue_detector = blue_median
    #yellow_detector = yellow_median
    #red_detector = red_median
    
    last_blockid = str(t_get_val(lrp_doc, BLOCKID="1")).split("\n")[-2]
    blockid = int(last_blockid)
    new_blockid = blockid+3 # add 3 for new job
    last_elementid = str(t_get_val(lrp_doc, ELEMENTID="1")).split("\n")[-2]
    elementid = int(last_elementid)+1
    last_us_name = str(t_get_val(lrp_doc, USNAME="2")).split("\n")[-2]
    us_name_no = int(re.sub(r"\D", "", last_us_name))
    block_name = etree.XSLT.strparam('job'+str(new_blockid))
    
    lrp_doc = t_copy_job(lrp_doc, BLOCKID=str(blockid),
                         NEWBLOCKID=str(new_blockid), ELEMENTID=str(elementid))
    lrp_doc = t_copy_job(lrp_doc, NEWBLOCKID=str(new_blockid),
                         BLOCKNAME=block_name)
    for j in range(4): # master + 3 sequences
        # add 2 for new job
        us_name = etree.XSLT.strparam('S'+str(us_name_no+j+2))
        lrp_doc = t_copy_job(lrp_doc, NEWBLOCKID=str(new_blockid),
                             SEQ=str(j+1), USNAME=us_name)

    lrp_doc = t_set_gain(lrp_doc, BLOCKID=str(new_blockid), CHANNEL="'green'",
                         GAIN=str(green_val))
    lrp_doc = t_set_gain(lrp_doc, BLOCKID=str(new_blockid), CHANNEL="'blue'",
                         GAIN=str(blue_median))
    lrp_doc = t_set_gain(lrp_doc, BLOCKID=str(new_blockid), CHANNEL="'yellow'",
                         GAIN=str(yellow_median))
    lrp_doc = t_set_gain(lrp_doc, BLOCKID=str(new_blockid), CHANNEL="'red'",
                         GAIN=str(red_median))
    
    for k, v in green.iteritems():
        if v == green_val:
            #assign job n+i to well k
            wellx = str(int(k[1:3])+1)
            welly = str(int(k[6:8])+1)
            for i in range(4): # disable 4x4 fields (all)
                for j in range(4):
                    xml_doc = t_enable(xml_doc, WELLX=wellx, WELLY=welly,
                                       FIELDX=str(j+1), FIELDY=str(i+1),
                                       ENABLE="'false'", JOBID=str(new_blockid),
                                       JOBNAME=block_name, DRIFT="'true'")
            for i in range(2): # 2x2 fields, (2,2)(2,3)(3,2)(3,3)
                for j in range(2):
                    xml_doc = t_enable(xml_doc, WELLX=wellx, WELLY=welly,
                                       FIELDX=str(j+2), FIELDY=str(i+2),
                                       ENABLE="'true'", JOBID=str(new_blockid),
                                       JOBNAME=block_name, DRIFT="'true'")

# Enable U00--V00--X00--Y00, for start position calibration
xml_doc = t_enable(xml_doc, WELLX=str(1), WELLY=str(1), FIELDX=str(1),
                   FIELDY=str(1), ENABLE="'true'", DRIFT="'true'")

# Save the xml to file
lrp_doc.write(lrp_input[0:-4]+'_new.lrp', method="xml", pretty_print=False)
xml_doc.write(xml_input[0:-4]+'_new.xml', pretty_print=False)
