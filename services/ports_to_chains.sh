#!/bin/bash
fil="$6"
declare -i i
i=1
while (( $i < 5 )); do
	line="$(source utility/get_line.sh $i $fil)"
	if [[ "$line" != "" ]]; then
		if (( $i == 1 )); then
			for sport in $line; do
				./ipt_traverse.sh -t "$1" -A "$3" -r "-p tcp --sport $sport" -j "$5 -l files/chains"
			done
		fi
		if (( $i == 2 )); then
			for dport in $line; do
				./ipt_traverse.sh -t "$2" -A "$3" -r "-p tcp --dport $dport" -j "$5 -l files/chains"
			done
		fi
		if (( $i == 3 )); then
			for sport in $line; do
				./ipt_traverse.sh -t "$1" -A "$4" -r "-p udp --sport $sport" -j "$5 -l files/chains"
			done
		fi
		if (( $i == 4 )); then
			for dport in $line; do
				./ipt_traverse.sh -t "$2" -A "$4" -r "-p udp --dport $dport" -j "$5 -l files/chains"
			done
		fi
	fi
	i=$i+1
done
