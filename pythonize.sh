for in_file in *_horizontal_*.h
do
    py_file=${in_file%.*}.py
    bin_file=${in_file%.*}.bin
    echo $in_file' -> '$py_file
    
cat > $py_file <<PY_HEADER
import re
FONT = bytes((
PY_HEADER

    cat $in_file | grep x | tr -d '{}' | cut -d'/' -f1 >> $py_file

cat >> $py_file <<PY_FOOTER
))

if __name__ == "__main__":
    f = "$bin_file"
    dim = (int(x) for x in re.match(r"(\d+)x(\d+).*", f, re.I).groups())
    with open(f, "wb") as outfile:
        # Write a byte each for the character width, character height.
        outfile.write(bytes(dim))#TODO: extract from file name
        # Now write all of the font character bytes.
        for font_byte in FONT:
            outfile.write(font_byte.to_bytes(1, "big"))
PY_FOOTER
    echo $py_file' -> '$bin_file
    python3 $py_file
done
