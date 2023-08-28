import os
import subprocess


dirs = os.listdir("./")
avoid_list = [
    "autotfsec.py", 
    "scripts", 
    "main.tf:Zone.Identifier", 
    "main.tf",
    "output.txt"
]

for dir in dirs:
    if dir in avoid_list:
        continue

    command = subprocess.check_output(f"tfsec {dir} | tail -n 3",
        stderr=subprocess.STDOUT,
        shell=True)
    
    print(f"SCANNING -------> {dir} <-------")
    print(command.decode().split("!")[0])
