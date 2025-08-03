set_property SRC_FILE_INFO {cfile:d:/personal_archive/2025summer/Computer_Design_and_Practice/my_cpu/my_pipeline_cpu/proj_pipeline/proj_pipeline.srcs/sources_1/ip/cpuclk/cpuclk.xdc rfile:../../../proj_pipeline.srcs/sources_1/ip/cpuclk/cpuclk.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
