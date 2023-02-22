# For Converting Hex Array to Decimal Array
from ast import literal_eval
f = open("output.txt", "x")
while True:
    inp = input().strip().strip(",")
    if len(inp) == 1:
        break
    print(inp)
    conversion = literal_eval(inp)
    print(str(conversion)+",\n")
    f.write(str(conversion)+",\n")

f.close()