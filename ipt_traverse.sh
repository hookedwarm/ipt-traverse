#!/bin/bash
var_dir="files/"
trav_dir="${var_dir}traversals/"
dir_dir="${var_dir}directions/"
swap_dir="${var_dir}swaps/"
action=""
rule_num=""
# rule arguments passed
declare -i rulenum
rulenum=0
chain_pattern=""
chain_path=""
chain_prefix=""
traversal=""
declare -a rule[1000]
declare -a rule_trav[1000]
declare -a swap[1000]
target_pattern=""
target_path=""
target_prefix=""
option=""
pattern=""
direction=""
declare -i debug
debug=1
#debug=0
chain=""
target=""
declare -i andlog
andlog=0
and_log=""
and_log_pattern=""
and_log_path=""
and_log_prefix=""
declare -i insert
insert=1
declare -i rule_trigger
rule_trigger=0
declare -a direction[1000]
declare -i clr
clr=0
while (( clr < 1000 )); do
	direction[$clr]=""
	rule[$clr]=""
	rule_trav[$clr]=""
	swap[$clr]=""
	clr=$clr+1
done
# PARSE ARGUMENTS
while [[ "$1" != "" ]]; do
	if [[ "$1" == "-d" || "$1" == "-D" ]]; then
		direction[$rulenum-1]="$2"
		shift
		shift
	fi
	if [[ "$1" == "-s" || "$1" == "-S" ]]; then
		# if the argument following the -s option has no dash
		if [[ $(echo "$2" | cut -f 1 -d '-') == $(echo "$2" | cut -f 2 -d '-') ]]; then
			swap[$rulenum-1]="$2"
			shift
			shift
		else
			# this is a placeholder for processing below
			swap[$rulenum-1]="default"
			shift
		fi
	fi
	if [[ "$1" == "-t" || "$1" == "-T" ]]; then
		# a set of chain / table combinations
		traversal="$2"
		shift
		shift
	fi
	if [[ "$1" == "-a" || "$1" == "-A" ]]; then
		# the chain prefix to prepend on a series (chain / table combinations) in a traversal
		chain_pattern="$2"
		action="-A"
		shift
		shift
	fi
	if [[ "$1" == "-n" || "$1" == "-N" ]]; then
		chain_pattern="$2"
		action="-N"
		shift
		shift
	fi
	if [[ "$1" == "-i" || "$1" == "-I" ]]; then
		chain_pattern="$2"
		action="-I"
		shift
		shift
		if [[ "$action" == "-I" ]]; then
			insert=$1
			shift
		fi
	fi
	if [[ "$1" == "-r" || "$1" == "-R" ]]; then
		# iptables rule
		rule[$rulenum]="$2"
		rulenum=$rulenum+1
		shift
		shift
	fi
	if [[ "$1" == "-p" || "$1" == "-P" ]]; then
		rule_trav[$rulenum-1]="$2"
		shift
		shift
	fi
	if [[ "$1" == "-j" || "$1" == "-J" ]]; then
		# target
		target_pattern="$2"
		shift
		shift
	fi
	if [[ "$1" == "-l" || "$1" == "-L" ]]; then
		andlog=1
		and_log_pattern="$2"
		shift
		shift
	fi
	if [[ "$1" == "-ll" || "$1" == "-LL" ]]; then
		andlog=2
		and_log_pattern="$2"
		shift
		shift
	fi
	if (( $rule_trigger == 1 )); then
		rulenum=$rulenum+1
		rule_trigger=0
	fi
done
declare -i a
a=0
declare -i b
b=0
declare -i de_count
de_count=0
declare -i gw_count
gw_count=0
declare -i short_count
short_count=0
declare -i long_count
long_count=0
while (( $a < $rulenum )); do
	if [[ "${swap[$a]}" == "default" ]]; then
		while (( $b < $rulenum )); do
			if (( $b != $a )) && [[ "${swap[$b]}" != "" ]] && [[ "${swap[$b]}" != "default" ]]; then
				dirtype="$(echo ${swap[$b]} | cut -f 1 -d '_')"
				if [[ "$(echo ${swap[$b]} | cut -f 1 -d '_')" == "$(echo ${swap[$b]} | cut -f 2 -d '_')" ]]; then
							len=""
				else
					len="_s"
				fi
				if [[ "$dirtype" == "dede" ]]; then
					de_count=$de_count+1
				fi
				if [[ "$dirtype" == "gw" ]]; then
					gw_count=$gw_count+1
				fi
				if [[ "$len" == "_s" ]]; then
					short_count=$short_count+1
				fi
				if [[ "$len" == "" ]]; then
					long_count=$long_count+1
				fi
			fi
			b=$b+1
		done
		if (( $gw_count != $de_count )) || (( $short_count != $long_count )); then
			if (( $gw_count > $de_count )); then
				dirtype="gw"
			else
				dirtype="dede"
			fi
			if (( $short_count > $long_count )); then
				len="_s"
			else
				len=""
			fi
		else
			if [[ "$traversal" != "" ]]; then
				dirtype="$(echo $traversal | cut -f 1 -d '/')"
				if [[ "$(echo $traversal | cut -f 1 -d '_')" == "$(echo $traversal | cut -f 2 -d '_')" ]]; then
					len=""
				else
					len="_s"
				fi
				if [[ "$dirtype" == "de" ]]; then
					dirtype="dede"
				fi
				swap[$a]="$dirtype$len"
			else
				# rule traversal
				if [[ "${rule_trav[$a]}" != "" ]]; then
					# use p
					dirtype="$(echo ${rule_trav[$a]} | cut -f 1 -d '/')"
					if [[ "$(echo ${rule_trav[$a]} | cut -f 1 -d '_')" == "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" ]]; then
						len=""
					else
						#if [[ "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" == "s" ]]; then
						#	len="_s"
						#fi
						len="_s"
					fi
					if [[ "$dirtype" == "de" ]]; then
						dirtype="dede"
					fi
					swap[$a]="$dirtype$len"
				else
					if [[ "${direction[$a]}" != "" ]]; then
						# use direction
						dirtype="$(echo ${direction[$a]} | cut -f 1 -d '_')"
						if [[ "$(echo ${direction[$a]} | cut -f 1 -d '_')" == "$(echo ${direction[$a]} | cut -f 2 -d '_')" ]]; then
							len=""
						else
							#if [[ "$(echo ${direction[$a]} | cut -f 2 -d '_')" == "s" ]]; then
							#	len="_s"
							#fi
							len="_s"
						fi
						if [[ "$dirtype" == "de" ]]; then
							dirtype="dede"
						fi
						swap[$a]="$dirtype$len"
					else
						swap[$a]="dede"
					fi
				fi
			fi
		fi
	fi
	a=$a+1
done
chain_prefix=""
chain_path=""
if [[ "$(echo $chain_pattern | cut -f 1 -d ' ')" == "-l" ]]; then
	chain_path=$(echo $chain_pattern | cut -f 2 -d ' ')
elif [[ "$(echo $chain_pattern | cut -f 2 -d ' ')" == "-l" ]]; then
	chain_prefix=$(echo $chain_pattern | cut -f 1 -d ' ')
	chain_path=$(echo $chain_pattern | cut -f 3 -d ' ')
else
	chain_prefix=$chain_pattern
fi
if [[ "$chain_path" == "" ]]; then
	chain_path="${var_dir}chains"
fi
if [[ "$(echo $target_pattern | cut -f 1 -d ' ')" == "-l" ]]; then
	target_path=$(echo $target_pattern | cut -f 2 -d ' ')
elif [[ "$(echo $target_pattern | cut -f 2 -d ' ')" == "-l" ]]; then
	target_prefix=$(echo $target_pattern | cut -f 1 -d ' ')
	target_path=$(echo $target_pattern | cut -f 3 -d ' ')
else
	target_prefix=$target_pattern
fi
if [[ "$(echo $and_log_pattern | cut -f 1 -d ' ')" == "-l" ]]; then
	and_log_path=$(echo "$and_log_pattern" | cut -f 2 -d ' ')
elif [[ "$(echo $and_log_pattern | cut -f 2 -d ' ')" == "-l" ]]; then
	and_log_prefix=$(echo "$and_log_pattern" | cut -f 1 -d ' ')
	and_log_path=$(echo "$and_log_pattern" | cut -f 3 -d ' ')
else
	and_log_prefix="$and_log_pattern"
fi
# default options
if [[ "$and_log_path" == "" ]]; then
	and_log_path="${var_dir}chains"
fi
if [[ "$action" == "" ]]; then
	action="-A"
fi
declare -a int[1000]
declare -a ext[1000]
declare -a src[1000]
declare -a dst[1000]
declare -a pro[1000]
declare -a spt[1000]
declare -a dpt[1000]
declare -a mac[1000]
declare -a mar[1000]
declare -a int_spec[1000]
declare -a ext_spec[1000]
declare -a src_spec[1000]
declare -a dst_spec[1000]
declare -a spt_spec[1000]
declare -a dpt_spec[1000]
declare -a mac_spec[1000]
declare -a rule_copy[1000]
clr=0
while (( clr < 1000 )); do
	int[$clr]=""
	ext[$clr]=""
	src[$clr]=""
	dst[$clr]=""
	pro[$clr]=""
	spt[$clr]=""
	dpt[$clr]=""
	mac[$clr]=""
	mar[$clr]=""
	int_spec[$clr]=""
	ext_spec[$clr]=""
	src_spec[$clr]=""
	dst_spec[$clr]=""
	spt_spec[$clr]=""
	dpt_spec[$clr]=""
	mac_spec[$clr]=""
	rule_copy[$clr]=""
	clr=$clr+1
done
a=0
while (( $a < $rulenum )); do
	# parse rule
	declare -i i
	i=1
	this=$(echo "${rule[$a]}" | cut -f $i -d ' ')
	while [[ "$this" != "" ]]; do
		declare -i invert
		invert=0
		if [[ "$this" == "!" ]]; then
			invert=1
			i=$i+1
			this=$(echo "${rule[$a]}" | cut -f $i -d ' ')
		fi
		if [[ "$this" == "-i" ]]; then
			int[$a]=$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')
			int_spec[$a]="1"
			if (( $invert == 1 )); then
				invert=0
				int_spec[$a]="2"
				i=$i+1
			fi
			i=$i+2
		elif [[ "$this" == "-o" ]]; then
			ext[$a]=$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')
			ext_spec[$a]="1"
			if (( $invert == 1 )); then
				invert=0
				ext_spec[$a]="2"
				i=$i+1
			fi
			i=$i+2
		elif [[ "$this" == "-s" ]]; then
			src[$a]=$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')
			src_spec[$a]="1"
			if (( $invert == 1 )); then
				invert=0
				src_spec[$a]="2"
				i=$i+1
			fi
			i=$i+2
		elif [[ "$this" == "-d" ]]; then
			dst[$a]=$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')
			dst_spec[$a]="1"
			if (( $invert == 1 )); then
				invert=0
				dst_spec[$a]="2"
				i=$i+1
			fi
			i=$i+2
		elif [[ "$this" == "-p" ]] && [[ "$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')" == "tcp" || "$(echo "${rule[$a]}" | cut -f $(($i+1)) -d ' ')" == "udp" ]] && [[ "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "--sport" || "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "--dport" ]]; then
			pro[$a]="-p $(echo ${rule[$a]} | cut -f $(($i+1)) -d ' ')"
			if (( $invert == 1 )); then
				invert=0
				pro[$a]="! -p $(echo ${rule[$a]} | cut -f $(($i+1)) -d ' ')"
			fi
			if [[ "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "--sport" ]] || [[ "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "!" && "$(echo "${rule[$a]}" | cut -f $(($i+3)) -d ' ')" == "--sport" ]]; then
				spt[$a]=$(echo ${rule[$a]} | cut -f $(($i+3)) -d ' ')
				spt_spec[$a]="1"
				if [[ "$(echo ${rule[$a]} | cut -f $(($i+2)) -d ' ')" == "!" ]]; then
					spt_spec[$a]="2"
					i=$i+1
				fi				
			fi
			if [[ "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "--dport" ]] || [[ "$(echo "${rule[$a]}" | cut -f $(($i+2)) -d ' ')" == "!" && "$(echo "${rule[$a]}" | cut -f $(($i+3)) -d ' ')" == "--dport" ]]; then
				dpt[$a]=$(echo ${rule[$a]} | cut -f $(($i+3)) -d ' ')
				dpt_spec[$a]="1"
				if [[ "$(echo ${rule[$a]} | cut -f $(($i+2)) -d ' ')" == "!" ]]; then
					dpt_spec[$a]="2"
					i=$i+1
				fi
			fi
			i=$i+4
		elif [[ "$this" == "-m" && "$(echo ${rule[$a]} | cut -f $(($i+1)) -d ' ')" == "mac" ]] || [[ "$this" == "-m" && "$(echo ${rule[$a]} | cut -f $(($i+1)) -d ' ')" == "!" && "$(echo ${rule[$a]} | cut -f $(($i+2)) -d ' ')" == "mac" ]]; then
			if [[ "$(echo ${rule[$a]} | cut -f $(($i+2)) -d ' ')" == "!" ]]; then
				mac[$a]=$(echo "${rule[$a]}" | cut -f $(($i+4)) -d ' ')
				mac_spec[$a]="2"
				i=$i+5
			else
				mac[$a]=$(echo "${rule[$a]}" | cut -f $(($i+3)) -d ' ')
				mac_spec[$a]="1"
				i=$i+4
			fi
		else
			rule_copy[$a]="${rule_copy[$a]} $this"
			i=$i+1
		fi
		this=$(echo "${rule[$a]}" | cut -f $i -d ' ')
	done
	a=$a+1
done
declare -i linecount
declare -i i
if [[ "$traversal" != "" ]]; then
	trav_path="$trav_dir$traversal"
else
	dirtype="de"
	a=0
	while (( $a < $rulenum )); do
		if [[ "$(echo ${swap[$a]} | cut -f 1 -d '_')" == "gw" ]]; then
			dirtype="gw"
		fi
		if [[ "$(echo ${direction[$a]} | cut -f 1 -d '_')" == "gw" ]]; then
			dirtype="gw"
		fi
		if [[ "$(echo ${rule_trav[$a]} | cut -f 1 -d '/')" == "gw" ]]; then
			dirtype="gw"
		fi
		a=$a+1
	done
	len=""
	a=0
	while (( $a < $rulenum )); do
		# TODO: this will easily break if naming is altered
		if [[ "$(echo ${swap[$a]} | cut -f 2 -d '_')" == "s" ]]; then
			len="_s"
		fi
		if [[ "$(echo ${direction[$a]} | cut -f 2 -d '_')" == "s" ]]; then
			len="_s"
		fi
		if [[ "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" == "s" ]]; then
			len="_s"
		fi
		a=$a+1
	done
	declare -i array_len
	array_len=32
	if [[ "$len" == "_s" ]]; then
		array_len=28
	fi
	declare -a rule_array[$array_len]
	declare -i c
	c=0
	while (( $c < $array_len )); do
		rule_array[$c]=""
		c=$c+1
	done
	# build traversal from rule traversals
	a=0
	while (( $a < $rulenum )); do
		# check to see if a rule_trav is given
		# add the lines from the rule_trav to a master tarversal list
		if [[ "${rule_trav[$a]}" != "" ]]; then
			linecount=$(cat $trav_dir${rule_trav[$a]} | wc -l)
			if (( $linecount == $array_len )); then
				i=0
				while (( $i < $linecount )); do	
					linenum=$i+1
					table="$(source ./utility/get_line.sh $linenum $trav_path)"
					if [[ "$table" != "" ]]; then
						if [[ "${rule_array[$i]}" != "" ]]; then
							rule_array[$i]="$table"
						fi
					fi
					i=$i+1
				done
			fi
		fi
	done
	# check to see if newly built traversal is empty
	i=0
	empty=""
	while (( $i < $array_len )); do
		empty="$empty${rule_array[$i]}"
		i=$i+1
	done
	if [[ "$empty" == "" ]]; then
		if [[ "$dirtype" == "gw" ]]; then
			traversal="gw/fwfw$len"
		else
			traversal="de/io$len"
		fi
		trav_path="$trav_dir$traversal"
	else
		# find a traversal that matches rule_array
		if [[ "$dirtype" == "gw" ]]; then
			# TODO
			echo -n ""
			# TEMPORARY
			traversal="${trav_dir}gw/fwfw$len"
		elif [[ "$dirtype" == "de" ]]; then
			# TODO
			echo -n ""
			# TEMPORARY
			traversal="${trav_dir}de/io$len"
		fi
		trav_path="$trav_dir$traversal"
	fi
fi
linecount=$(cat $trav_path | wc -l)
declare -i logmod
logmod=16
if (( $linecount == 14 || $linecount == 28 )); then
	logmod=14
	if [[ "$and_log_path" != "" && "$(echo $and_log_path | cut -f 2 -d '_')" != "s" ]]; then
		and_log_path="${and_log_path}_s"
	fi
	if [[ "$target_path" != "" && "$(echo $target_path | cut -f 2 -d '_')" != "s" ]]; then
		target_path="${target_path}_s"
	fi
	if [[ "$chain_path" != "" && "$(echo $chain_path | cut -f 2 -d '_')" != "s" ]]; then
		chain_path="${chain_path}_s"
	fi
fi
i=0
declare -i mod
mod=1
while (( $i < $linecount )); do
	final_rule=""
	declare -i linenum
	linenum=$(($i+1))
	table="$(source ./utility/get_line.sh $linenum $trav_path)"
	if [[ "$table" != "" ]]; then
		chain=$chain_prefix
		if [[ "$chain_path" != "" ]]; then
			chain="$chain$(source ./utility/get_line.sh $((${i}%${logmod}+1)) $chain_path)"
		fi
		target="-j $target_prefix"
		if [[ "$target_path" != "" ]]; then
			target="$target$(source ./utility/get_line.sh $((${i}%${logmod}+1)) $target_path)"
		fi
		and_log=$and_log_prefix
		if [[ "$and_log_path" != "" ]]; then
			and_log="$and_log$(source ./utility/get_line.sh $linenum $and_log_path)"
		fi
		if [[ "$action" == "-N" ]]; then
			target=""
		fi
		ipt_comm="iptables "
		if (( $debug == 1 )); then
			ipt_comm="echo iptables "
		fi
		a=0
		while (( $a < $rulenum )); do
			rule_table=""
			rule_traversal="${rule_trav[$a]}"
			if [[ "$rule_traversal" != "" ]]; then
				rule_table="$(source ./utility/get_line.sh $linenum ${trav_dir}$rule_traversal)"
			fi
			if [[ "$rule_traversal" == "" ]] || [[ "$rule_traversal" != "" && "$rule_table" != "" ]]; then
				dirtype="de"
				# is the traversal long or short
				len=""
				# if -d is not given
				if [[ "${direction[$a]}" == "" ]]; then
					b=0
					de_count=0
					gw_count=0
					short_count=0
					long_count=0
					while (( $b < $rulenum )); do
						if (( $b != $a )); then
							if [[ "${swap[$b]}" != "" ]]; then
								dirtype="$(echo ${swap[$b]} | cut -f 1 -d '_')"
								if [[ "$(echo ${swap[$b]} | cut -f 1 -d '_')" == "$(echo ${swap[$b]} | cut -f 2 -d '_')" ]]; then
									len=""
								else
									#if [[ "$(echo ${swap[$a]} | cut -f 2 -d '_')" == "s" ]]; then
									#	len="_s"
									#fi
									len="_s"
								fi
								if [[ "$dirtype" == "dede" ]]; then
									de_count=$de_count+1
								fi
								if [[ "$dirtype" == "gw" ]]; then
									gw_count=$gw_count+1
								fi
								if [[ "$len" == "_s" ]]; then
									short_count=$short_count+1
								fi
								if [[ "$len" == "" ]]; then
									long_count=$long_count+1
								fi
							fi
							if [[ "${rule_trav[$b]}" != "" ]]; then
								dirtype="$(echo ${rule_trav[$b]} | cut -f 1 -d '/')"
								if [[ "$(echo ${rule_trav[$a]} | cut -f 1 -d '_')" == "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" ]]; then
											len=""
								else
									#if [[ "$(echo ${swap[$a]} | cut -f 2 -d '_')" == "s" ]]; then
									#	len="_s"
									#fi
									len="_s"
								fi
								if [[ "${rule_trav[$a]}" != "" ]]; then
									if [[ "$dirtype" == "de" ]]; then
										de_count=$de_count+1
									fi
									if [[ "$dirtype" == "gw" ]]; then
										gw_count=$gw_count+1
									fi
									if [[ "$len" == "_s" ]]; then
										short_count=$short_count+1
									fi
									if [[ "$len" == "" ]]; then
										long_count=$long_count+1
									fi
								fi
							fi
						fi
						b=$b+1
					done
					# TODO: this might be better defaulting to gw if gw is anywhere
					if (( $gw_count != $de_count )) || (( $short_count != $long_count )); then
						if (( $gw_count > $de_count )); then
							dirtype="gw"
						else
							dirtype="de"
						fi
						if (( $short_count > $long_count )); then
							len="_s"
						else
							len=""
						fi

					else
						# if -p is not given
						if [[ "$(echo ${rule_trav[$a]} | cut -f 1 -d '/')" == "" ]]; then
							if [[ "${swap[$a]}" == "" ]]; then
								# if -t not given
								if [[ "$traversal" == "" ]]; then
									# use default 'de' for default traversal io
									dirtype="de"
									# use a traversal type with 16 table / chain combinations rather than 14
									len=""
								else
									# use t
									dirtype="$(echo $traversal | cut -f 1 -d '/')"
									if [[ "$(echo $traversal | cut -f 1 -d '_')" == "$(echo $traversal | cut -f 2 -d '_')" ]]; then
										len=""
									else
										#if [[ "$(echo $traversal | cut -f 2 -d '_')" == "s" ]]; then
										#	len="_s"
										#fi
										len="_s"
									fi
								fi

							else
								# use s
								dirtype="$(echo ${swap[$a]} | cut -f 1 -d '_')"
								if [[ "$dirtype" == "dede" ]]; then
									dirtype="de"
								fi
								if [[ "$(echo ${swap[$a]} | cut -f 1 -d '_')" == "$(echo ${swap[$a]} | cut -f 2 -d '_')" ]]; then
									len=""
								else
									#if [[ "$(echo ${swap[$a]} | cut -f 2 -d '_')" == "s" ]]; then
									#	len="_s"
									#fi
									len="_s"
								fi
							fi
						else
							# use p
							dirtype="$(echo ${rule_trav[$a]} | cut -f 1 -d '/')"
							if [[ "$(echo ${rule_trav[$a]} | cut -f 1 -d '_')" == "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" ]]; then
								len=""
							else
								#if [[ "$(echo ${rule_trav[$a]} | cut -f 2 -d '_')" == "s" ]]; then
								#	len="_s"
								#fi
								len="_s"
							fi
						fi
					fi
				else
					# use d
					dirtype="$(echo ${direction[$a]} | cut -f 1 -d '_')"
					if [[ "$(echo ${direction[$a]} | cut -f 1 -d '_')" == "$(echo ${direction[$a]} | cut -f 2 -d '_')" ]]; then
						len=""
					else
						#if [[ "$(echo ${direction[$a]} | cut -f 2 -d '_')" == "s" ]]; then
						#	len="_s"
						#fi
						len="_s"
					fi
				fi
				thisdir="$(source ./utility/get_line.sh $(($linenum)) ${dir_dir}$dirtype$len)"
				# build new rule
				new_rule=""
				if [[ "$thisdir" == "1" ]]; then
					# drop out stuff
					if [[ "${int_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -i ${int[$a]}"
					elif [[ "${int_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -i ${int[$a]}"
					fi
					if [[ "${src_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -s ${src[$a]}"
					elif [[ "${src_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -s ${src[$a]}"
					fi
					if [[ "${dst_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -d ${dst[$a]}"
					elif [[ "${dst_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -d ${dst[$a]}"
					fi
					if [[ "${spt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --sport ${spt[$a]}"
						fi
					elif [[ "${spt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --sport ${spt[$a]}"
						fi
					fi
					if [[ "${dpt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --dport ${dpt[$a]}"
						fi
					elif [[ "${dpt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --dport ${dpt[$a]}"
						fi
					fi
					if [[ "${mac_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -m mac --mac-source ${mac[$a]}"
					elif [[ "${mac_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} -m mac ! --mac-source ${mac[$a]}"
					fi
				elif [[ "$thisdir" == "0" ]]; then
					# drop in stuff
					# drop interface
					# drop mac
					if [[ "${ext_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -o $ext"
					elif [[ "${ext_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -o $ext"
					fi
					if [[ "${src_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -s ${src[$a]}"
					elif [[ "${src_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -s ${src[$a]}"
					fi
					if [[ "${dst_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -d ${dst[$a]}"
					elif [[ "${dst_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -d ${dst[$a]}"
					fi
					if [[ "${spt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --sport ${spt[$a]}"
						fi
					elif [[ "${spt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --sport ${spt[$a]}"
						fi
					fi
					if [[ "${dpt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --dport ${dpt[$a]}"
						fi
					elif [[ "${dpt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --dport ${dpt[$a]}"
						fi
					fi
				#elif [[ "$thisdir" == "2" ]]; then
				else
					# don't drop in or out
					if [[ "${int_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -i ${int[$a]}"
					elif [[ "${int_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -i ${int[$a]}"
					fi
					if [[ "${ext_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -o $ext"
					elif [[ "${ext_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -o $ext"
					fi
					if [[ "${src_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -s ${src[$a]}"
					elif [[ "${src_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -s ${src[$a]}"
					fi
					if [[ "${dst_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -d ${dst[$a]}"
					elif [[ "${dst_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} ! -d ${dst[$a]}"
					fi
					if [[ "${spt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --sport ${spt[$a]}"
						fi
					elif [[ "${spt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --sport ${spt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --sport ${spt[$a]}"
						fi
					fi
					if [[ "${dpt_spec[$a]}" == "1" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp --dport ${dpt[$a]}"
						fi
					elif [[ "${dpt_spec[$a]}" == "2" ]]; then
						if [[ "${pro[$a]}" == "-p tcp" ]]; then
							new_rule="${new_rule} -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p tcp" ]]; then
							new_rule="${new_rule} ! -p tcp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "-p udp" ]]; then
							new_rule="${new_rule} -p udp ! --dport ${dpt[$a]}"
						elif [[ "${pro[$a]}" == "! -p udp" ]]; then
							new_rule="${new_rule} ! -p udp ! --dport ${dpt[$a]}"
						fi
					fi
					if [[ "${mac_spec[$a]}" == "1" ]]; then
						new_rule="${new_rule} -m mac --mac-source ${mac[$a]}"
					elif [[ "${mac_spec[$a]}" == "2" ]]; then
						new_rule="${new_rule} -m mac ! --mac-source ${mac[$a]}"
					fi
				fi
				final_rule="$final_rule $new_rule ${rule_copy[$a]}"
			fi
			a=$a+1
		done
		if (( $andlog == 1 )); then
			# add log stuff to target
			target="$target --log-prefix ${and_log_prefix}$(source ./utility/get_line.sh $((${i}%${logmod}+1)) $and_log_path)"
		fi
		if (( $andlog == 2 )); then
			log_target="-j LOG --log-prefix ${and_log_prefix}$(source ./utility/get_line.sh $((${i}%${logmod}+1)) $and_log_path)"
			${ipt_comm} -t ${table} ${action} ${chain} ${final_rule} ${log_target}
		fi
		# run command
		${ipt_comm} -t ${table} ${action} ${chain} ${final_rule} ${target}
	fi
	a=0
	while (( $a < $rulenum )); do
		if [[ "${swap[$a]}" != "" ]]; then
			dir_var="$(source ./utility/get_line.sh $(($linenum+1)) ${swap_dir}${swap[$a]})"
			if [[ "$dir_var" != "" ]]; then
				#swap i/o src/dst sport/dport yes mac src / no mac src
				tmp="${int[$a]}"
				if [[ "${ext[$a]}" != "" ]]; then
					int[$a]="${ext[$a]}"
				fi
				if [[ "$tmp" != "" ]]; then
					ext[$a]="$tmp"
				fi
				tmp="${src[$a]}"
				if [[ "${dst[$a]}" != "" ]]; then
					src[$a]="${dst[$a]}"
				fi
				if [[ "$tmp" != "" ]]; then
					dst[$a]="$tmp"
				fi
				tmp="${spt[$a]}"
				if [[ "${dpt[$a]}" != "" ]]; then
					spt[$a]="${dpt[$a]}"
				fi
				if [[ "$tmp" != "" ]]; then
					dpt[$a]="$tmp"
				fi
				if [[ "${int_spec[$a]}" == "1" ]] && [[ "${ext_spec[$a]}" == "" ]]; then
					int_spec[$a]=""
					ext_spec[$a]="1"
				elif [[ "${ext_spec[$a]}" == "1" ]] && [[ "${int_spec[$a]}" == "" ]]; then
					ext_spec[$a]=""
					int_spec[$a]="1"
				fi
				if [[ "${src_spec[$a]}" == "1" ]] && [[ "${dst_spec[$a]}" == "" ]]; then
					src_spec[$a]=""
					dst_spec[$a]="1"
				elif [[ "${dst_spec[$a]}" == "1" ]] && [[ "${src_spec[$a]}" == "" ]]; then
					dst_spec[$a]=""
					src_spec[$a]="1"
				fi
				if [[ "${spt_spec[$a]}" == "1" ]] && [[ "${dpt_spec[$a]}" == "" ]]; then
					spt_spec[$a]=""
					dpt_spec[$a]="1"
				elif [[ "${dpt_spec[$a]}" == "1" ]] && [[ "${spt_spec[$a]}" == "" ]]; then
					dpt_spec[$a]=""
					spt_spec[$a]="1"
				fi
			fi
		fi
		a=$a+1
	done
	i=$i+1
done
