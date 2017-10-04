
action = 'simulation'
sim_tool = 'iverilog'
sim_top = 'tb_conv_8to24'
sim_post_cmd = 'vvp tb_conv_8to24.vvp'
iverilog_opt = '-Wall'

files = [ '../../tb/tb_conv8to24.v' ]

modules = {
    'local' : '../..'
}
