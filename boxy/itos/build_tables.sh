#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: ./build_tables.sh <scenarios_dir>"
    exit
fi

rm output/loads/ats*
rm output/loads/rts*

echo "Compiling stored command sequences in $1..."

seq_files=$(find $1 -iname '*.[ar]tf' | sort)

for f in $seq_files
do
    # Create a temporary copy of the file that has long RTS names replaced with numbers
    tmp_file=$(mktemp)
    sed -r 's/rts_([0-9]+)\S*/\1/g' $f > $tmp_file

    filename="$(basename $f)"
    ext="${f##*.}"

    echo "   $filename"

    if [ "$ext" == "atf" ]
    then
        [[ "$filename" =~ scn([0-9]+) ]]
        # Build the destination filename using the scenario number
        scn_num="${BASH_REMATCH[1]}"
        destfile="ats_scn${scn_num}.tbl"

        itosrun leditor -nogui -i $tmp_file -o $destfile -l ats -d "Scenario $scn_num ATS" -t "SC_APP.ATS_TBL1"

        if [ -f output/loads/$destfile ]
        then
            cp output/loads/$destfile /srv/nfs/schooner/atbl
            cp output/loads/$destfile /srv/nfs/schooner_1pil/atbl
        else
            echo "Error building ATS $filename!"
            exit
        fi
    else
        # Determine the number of the RTS and zero-extend it for the table's fully-qualified name
        [[ "$filename" =~ rts_([0-9]+) ]]
        rts_num=$(printf "%03u" "${BASH_REMATCH[1]}")

        # Construct the destination table file name
        name="${filename%.*}"
        destfile=${name}.tbl

        # Create a simple description for what the RTS does
        [[ "$name" =~ rts_[0-9]+_(.*) ]]
        description=${BASH_REMATCH[1]:0:32}

        itosrun leditor -nogui -i $tmp_file -o $destfile -l rts -d "$description" -t "SC_APP.RTS_TBL$rts_num"

        if [ -f output/loads/$destfile ]
        then
            cp output/loads/$destfile /srv/nfs/schooner/rtbl
            cp output/loads/$destfile /srv/nfs/schooner_1pil/rtbl
        else
            echo "Error building RTS $filename!"
            exit
        fi
    fi

    rm $tmp_file
done
