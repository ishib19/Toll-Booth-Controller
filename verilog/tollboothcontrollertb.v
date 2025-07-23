module tollboothcontrollertb();

  reg clk, reset;
  reg vehicle_detect;
  reg rfid_present, rfid_valid, rfid_sufficient;
  reg manual_coin, manual_card;
  reg vehicle_passgate;
  reg maintenance_mode;
  reg updaterate;
  reg [1:0] vehicle_class;
  reg [7:0] rate_input;
  reg reset_counters;

  wire gateopen, gateclose;
  wire [15:0] vehiclecount0, vehiclecount1, vehiclecount2;
  wire [15:0] totalrevenue0, totalrevenue1, totalrevenue2;
  wire [7:0] evasioncount;

  tollboothcontroller demo (
    .clk(clk), .reset(reset),
    .vehicle_detect(vehicle_detect),
    .rfid_present(rfid_present),
    .rfid_valid(rfid_valid),
    .rfid_sufficient(rfid_sufficient),
    .manual_coin(manual_coin),
    .manual_card(manual_card),
    .vehicle_passgate(vehicle_passgate),
    .maintenance_mode(maintenance_mode),
    .updaterate(updaterate),
    .vehicle_class(vehicle_class),
    .rate_input(rate_input),
    .reset_counters(reset_counters),
    .gateopen(gateopen),
    .gateclose(gateclose),
    .vehiclecount0(vehiclecount0),
    .vehiclecount1(vehiclecount1),
    .vehiclecount2(vehiclecount2),
    .totalrevenue0(totalrevenue0),
    .totalrevenue1(totalrevenue1),
    .totalrevenue2(totalrevenue2),
    .evasioncount(evasioncount)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("tollbooth_tb.vcd");
    $dumpvars(0, Toll_Booth_Controller_tb);

    // Initial values
    clk = 0;
    reset = 1;
    vehicle_detect = 0;
    rfid_present = 0;
    rfid_valid = 0;
    rfid_sufficient = 0;
    manual_coin = 0;
    manual_card = 0;
    vehicle_passgate = 0;
    maintenance_mode = 0;
    updaterate = 0;
    vehicle_class = 0;
    rate_input = 0;
    reset_counters = 0;

    #10 reset = 0;

    //1 Normal RFID -car 
    #10 vehicle_detect = 1; rfid_present = 1; rfid_valid = 1; rfid_sufficient = 1; vehicle_class = 2'd0;
    #20 vehicle_detect = 0; rfid_present = 0; rfid_valid = 0; rfid_sufficient = 0;
    #10 vehicle_passgate = 1;
    #10 vehicle_passgate = 0;

    //2 RFID fail, manual coin -truck
    #10 vehicle_detect = 1; rfid_present = 0; vehicle_class = 2'd1;
    #20 manual_coin = 1;
    #10 manual_coin = 0;
    #10 vehicle_passgate = 1;
    #10 vehicle_passgate = 0;

    //3 RFID fail, manual card -bus
    #10 vehicle_detect = 1; rfid_present = 0; vehicle_class = 2'd2;
    #20 manual_card = 1;
    #10 manual_card = 0;
    #10 vehicle_passgate = 1;
    #10 vehicle_passgate = 0;

    //4 Vehicle evasion -truck
    #10 vehicle_detect = 1; rfid_present = 0; vehicle_class = 2'd1;
    #20 vehicle_detect = 0; vehicle_passgate = 1;  // No valid payment
    #10 vehicle_passgate = 0;

    //5 Update toll rate -truck
    #10 updaterate = 1; vehicle_class = 2'd2; rate_input = 8'd200;
    #10 updaterate = 0;

    // Confirm it by sending one more RFID
    #10 vehicle_detect = 1; rfid_present = 1; rfid_valid = 1; rfid_sufficient = 1; vehicle_class = 2'd2;
    #20 vehicle_detect = 0; rfid_present = 0; rfid_valid = 0; rfid_sufficient = 0;
    #10 vehicle_passgate = 1;
    #10 vehicle_passgate = 0;

    //6 Maintenance mode 
    #10 maintenance_mode = 1;
    #20 maintenance_mode = 0;

    #50 $finish;
  end
endmodule
