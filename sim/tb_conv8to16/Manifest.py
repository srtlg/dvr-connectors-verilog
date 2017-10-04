
action = 'simulation'
sim_tool = 'iverilog'
sim_top = 'tb_conv_8to16'
sim_post_cmd = 'vvp tb_conv_8to16.vvp'
iverilog_opt = '-Wall'

files = [ '../../tb/tb_conv8to16.v' ]

modules = {
    'local' : '../..'
}
