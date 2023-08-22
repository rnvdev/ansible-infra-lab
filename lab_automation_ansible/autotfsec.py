import os

dirs = os.listdir("./")
command = "tfsec "
avoid_list = ["autotfsec.py", "scripts", "main.tf:Zone.Identifier", "main.tf"]

for dir in dirs:
    if dir in avoid_list:
        continue
    print(f"SCANNING-------> {dir} <-----")
    os.system("tfsec " + dir + "/")
