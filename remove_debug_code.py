import sys


argv = sys.argv
argc = len(argv)

if argc < 2:
    print("Usage: python3", argv[0], "<file_to_process>")
    sys.exit()

begin_flag  = "# @debug"
end_flag    = "# @debug end"

filename = argv[1]


source_file = open(filename, "r")
source = source_file.read()
source_file.close()


lines = source.split("\n")

keep_line = True

res = ""

for i in range(0, len(lines)):
    line = lines[i]

    if line.startswith(begin_flag):
        keep_line = True
    elif line.startswith(end_flag):
        keep_line = False

    if keep_line:
        res += line + "\n"


parts = filename.split(".")
parts.insert(len(parts) - 2, "nodebug")
res_filename = ".".join(parts)

res_file = open(res_filename, "xt")
res_file.write(res)
res_file.close()
