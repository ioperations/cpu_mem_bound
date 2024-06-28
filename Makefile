
default:
	gcc cpu_mem_bound.c -g -O0 -fno-omit-frame-pointer -o cpu_mem_bound
	# intel cpu
	# sudo perf record -e cpu/event=0xa2,name=resource_stalls_any/ -e cpu/event=0x3c,name=cpu_clk_unhalted_thread_p/ --call-graph fp -F 197 ./cpu_mem_bound
	# amdcpu
	sudo perf record -e cpu/event=0xa2,name=resource_stalls_any/ -e cpu/event=0x76,name=cpu_clk_unhalted_thread_p/ --call-graph fp -F 197 ./cpu_mem_bound
	sudo perf script > out.perf
	
	./FlameGraph/stackcollapse-perf.pl --event-filter=cpu_clk_unhalted_thread_p out.perf > out.folded.cycles
	./FlameGraph/stackcollapse-perf.pl --event-filter=resource_stalls_any out.perf > out.folded.stalls
	./FlameGraph/difffolded.pl -n out.folded.stalls out.folded.cycles | FlameGraph/flamegraph.pl --title "CPI Flame Graph: blue=stalls, red=instructions" --width=900 > cpi_flamegraph_small.svg

clean:
	-@ rm -rf cpu_mem_bound out.folded.cycles out.folded.stalls perf.data perf.data.old out.perf cpi_flamegraph_small.svg

