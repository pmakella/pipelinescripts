import csv
#from xlsxwriter.workbook import Workbook
from xlwt import *

if len(sys.argv)<>4:
	print 'Usage: python writetsvtoexcel.py <file for sheet1> <file for sheet2> <output excel filename>' 
	sys.exit(0)

# Add some command-line logic to read the file names.
tsv_file1 = sys.argv[1]
tsv_file2 = sys.argv[2]
xlsx_file = sys.argv[3]

print tsv_file1
print tsv_file2
print xlsx_file

# Create an workbook object and add a worksheet.
wb = Workbook()
ws1 = wb.add_sheet(tsv_file1)
ws2 = wb.add_sheet(tsv_file2)

# Create a TSV file reader.
with open(tsv_file1, 'rb') as f:
    reader = csv.reader(f,delimiter='\t')
    
    for (row_num,row) in enumerate(reader):
	for (counter, data) in enumerate(row):
		ws1.write(row_num, counter, data)
#        print row


with open(tsv_file2, 'rb') as f2:
    reader2 = csv.reader(f2,delimiter='\t')

    for (row_num,row) in enumerate(reader2):
        for (counter, data) in enumerate(row):
                ws2.write(row_num, counter, data)
#        print row



# Close the XLSX file.
wb.save(xlsx_file)


