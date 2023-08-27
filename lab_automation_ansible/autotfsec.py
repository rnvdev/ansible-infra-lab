import os

dirs = os.listdir("./")
command = "tfsec "
avoid_list = ["autotfsec.py", "scripts", "main.tf:Zone.Identifier", "main.tf","output.txt"]
scan_result = []

for dir in dirs:
    if dir in avoid_list:
        continue
    print(f"SCANNING -------> {dir} <-------")
    os.system("tfsec " + dir + "/ > output.txt")

    with open("output.txt", "r") as file:
        last_line = file.readlines()[-3]
        scan_result.append(last_line)
        print(f"SCAN RESULT: {last_line}")
        
