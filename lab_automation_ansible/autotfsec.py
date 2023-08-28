import os
import subprocess


dirs = os.listdir("./")
avoid_list = [
    "autotfsec.py", 
    "scripts", 
    "main.tf:Zone.Identifier", 
    "main.tf"
]

for dir in dirs:
    if dir in avoid_list:
        continue

    print(f"SCANNING -------> {dir} <-------")

    command = subprocess.check_output(f"tfsec {dir} | tail -n 3",
        stderr=subprocess.STDOUT,
        shell=True)
    
    print(command.decode().split("!")[0])
