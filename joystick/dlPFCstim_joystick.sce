scenario = "Joystick";
default_font_size = 36;
#write_codes = true;
screen_width=1920;
screen_height=1080;
screen_bit_depth = 16;
pulse_width = 20;  
default_output_port=1;
response_logging = log_active;
response_port_output = true; 
response_matching = simple_matching;
active_buttons = 1;
button_codes = 1;
target_button_codes = 1;
# set these to screen measurements in cm
screen_width_distance = 192;
screen_height_distance = 104;
# set max_y to 1/2 screen_height_distance
max_y = 13;
pcl_file = "dlPFCstim_joystick.pcl";

begin;

picture {  background_color = 255,255,255;
   ellipse_graphic{ color = 255,0,0; ellipse_height = .2; ellipse_width = .2; }; #target
   x = 0; y = 0; on_top = true;
	ellipse_graphic{ color = 0,0,0; ellipse_height = .8; ellipse_width = .8;}; #cursor
   x = 0; y = 0; on_top = false; } pic1;   

picture {
   text { caption = " "; font_size = 24; } text1;
   x = 0; y = 0;
} pic2;