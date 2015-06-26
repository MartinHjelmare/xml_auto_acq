# Call R script for all csv files (wells) and collect output

import fnmatch
import os
import sys
import subprocess
import re
import csv

working_dir = sys.argv[1]
imaging_dir = sys.argv[2]
first_std_dir = sys.argv[3]
sec_std_dir = sys.argv[4]
first_r_script = working_dir+"gain.r"
sec_r_script = working_dir+"gain_change_objectives.r"
first_initialgains_file = sys.argv[5]
sec_initialgains_file = sys.argv[6]

def search_files(file_list, rootdir, _match_string):
    for root, dirnames, filenames in os.walk(rootdir):
        for filename in fnmatch.filter(filenames, _match_string):
            file_list.append(os.path.join(root, filename))
    return file_list

first_files = []
first_files = search_files(first_files, imaging_dir, "*.csv")

first_std_files = []
sec_std_files = []
first_std_files = search_files(first_std_files, first_std_dir, "*.csv")
sec_std_files = search_files(sec_std_files, sec_std_dir, "*.csv")

first_filebases = []
wells = []
first_std_filebases = []
sec_std_filebases = []
garbage_wells = []

def strip_fun(files, filebases, _wells):
    for f in files:
        #print(re.sub('C\d\d.+$', '', f))
        filebases.append(re.sub('C\d\d.+$', '', f))
        wellmatch = re.search('U\d\d--V\d\d--', f)

        if wellmatch:                      
            #print('found', wellmatch.group())
            _wells.append(wellmatch.group())

        else:
            print 'did not find'
    return

strip_fun(first_files, first_filebases, wells)
strip_fun(first_std_files, first_std_filebases, garbage_wells)
strip_fun(sec_std_files, sec_std_filebases, garbage_wells)

first_filebases = sorted(list(set(first_filebases)))
wells = sorted(list(set(wells)))

first_std_filebases = sorted(list(set(first_std_filebases)))
sec_std_filebases = sorted(list(set(sec_std_filebases)))

first_gain_dicts = []
sec_gain_dicts = []

def process_output(dict_list, well_list, i, output):
    dict_list.append({ "well": well_list[i], "green": output.split()[0] ,
        "blue": output.split()[1] , "yellow": output.split()[2] ,
        "red": output.split()[3]})
    return dict_list

# for all wells run R script
for i in range(len(first_filebases)):
    print(first_filebases[i])
    print(wells[i])
    # Run with "Rscript path/to/script/gain.r path/to/working/dir/
    # path/to/histogram-csv-filebase path/to/initialgains/csv-file"
    # from linux command line.
    r_output = subprocess.check_output(["Rscript", first_r_script,
            imaging_dir, first_filebases[i], first_initialgains_file])

    first_gain_dicts = process_output(first_gain_dicts, wells, i, r_output)

    input_gains = (""+r_output.split()[0]+" "+r_output.split()[1]+" "+
                    r_output.split()[2]+" "+r_output.split()[3]+"")
    r_output = subprocess.check_output(["Rscript", sec_r_script,
            first_std_dir, first_std_filebases[0],
            first_initialgains_file, input_gains, sec_std_dir,
            sec_std_filebases[0], sec_initialgains_file])
    # testing
    print(r_output)
    
    sec_gain_dicts = process_output(sec_gain_dicts, wells, i, r_output)

def write_csv(path, dict_list):
    with open(path, 'wb') as f:
        keys = ["well", "green", "blue", "yellow", "red"]
        w = csv.DictWriter(f, keys)
        w.writeheader()
        w.writerows(dict_list)

write_csv(working_dir+"first_output_gains.csv", first_gain_dicts)
write_csv(working_dir+"sec_output_gains.csv", sec_gain_dicts)
