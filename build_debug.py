import subprocess
import sys

# Run with shell=True to find the flutter batch file
res = subprocess.run('flutter build appbundle --release --verbose', 
                     shell=True, 
                     cwd=r'c:\Users\veo18\Desktop\Law\law-genie', 
                     capture_output=True, 
                     text=True)

with open('final_build_log.txt', 'w', encoding='utf-8') as f:
    f.write(f"RETURN CODE: {res.returncode}\n")
    if res.stderr:
        f.write("STDERR TAIL:\n")
        f.write(res.stderr[-5000:])
    if res.stdout:
        f.write("STDOUT TAIL:\n")
        f.write(res.stdout[-5000:])
