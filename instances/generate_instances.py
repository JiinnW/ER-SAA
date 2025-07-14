import os

nRep = 200
with open("instances_case2.txt", "w") as f:
    for rep in range(1, (nRep+1)):
        f.write(f"{rep} 1 1 3\n")

