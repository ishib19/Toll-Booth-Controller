module tollboothcontroller (
    input clk, reset,
    input vehicle_detect,
    input rfid_present, rfid_valid, rfid_sufficient,
    input manual_coin, manual_card,
    input vehicle_passgate,
    input maintenance_mode,
    input updaterate,
    input [1:0] vehicle_class,
    input [7:0] rate_input,
    input reset_counters,

    output reg gateopen, gateclose,
    output reg [15:0] vehiclecount0, vehiclecount1, vehiclecount2, //0 car, 1 truck, 2 bus
    output reg [15:0] totalrevenue0, totalrevenue1, totalrevenue2,
    output reg [7:0] evasioncount
);

// Internal control
reg readrfid, askmanual, showerror, evasionalarm;
reg countvehicle, countrevenue, logevasion;

// FSM States
parameter idle = 4'd0,
          read_rfid = 4'd1,
          rfid_ok = 4'd2,
          rfid_fail = 4'd3,
          wait_manual = 4'd4,
          manual_ok = 4'd5,
          manual_fail = 4'd6,
          open_gate = 4'd7,
          gate_evasion = 4'd8,
          maintenance = 4'd9;

reg [3:0] state, nextstate;

reg [7:0] tollrates0, tollrates1, tollrates2;

// Current state
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= idle;
    else
        state <= nextstate;
end

// Next state logic
always @(*) begin
    readrfid = 0;
    gateopen = 0;
    gateclose = 1;
    askmanual = 0;
    showerror = 0;
    evasionalarm = 0;
    countvehicle = 0;
    countrevenue = 0;
    logevasion = 0;
    nextstate = state;

    case (state)
        idle: begin
            if (maintenance_mode)
                nextstate = maintenance;
            else if (vehicle_detect)
                nextstate = read_rfid;
        end

        read_rfid: begin
            readrfid = 1;
            if (rfid_present) begin
                if (rfid_valid && rfid_sufficient)
                    nextstate = rfid_ok;
                else
                    nextstate = rfid_fail;
            end else
                nextstate = rfid_fail;
        end

        rfid_ok: begin
            countvehicle = 1;
            countrevenue = 1;
            nextstate = open_gate;
        end

        rfid_fail: begin
            askmanual = 1;
            nextstate = wait_manual;
        end

        wait_manual: begin
            if (manual_coin || manual_card)
                nextstate = manual_ok;
        end

        manual_ok: begin
            countvehicle = 1;
            countrevenue = 1;
            nextstate = open_gate;
        end

        manual_fail: begin
            showerror = 1;
            nextstate = wait_manual;
        end

        open_gate: begin
            gateopen = 1;
            gateclose = 0;
            if (vehicle_passgate)
                nextstate = idle;
        end

        gate_evasion: begin
            evasionalarm = 1;
            logevasion = 1;
            nextstate = idle;
        end

        maintenance: begin
            if (!maintenance_mode)
                nextstate = idle;
        end

        default: nextstate = idle;
    endcase

    if ((state != open_gate) && vehicle_passgate)
        nextstate = gate_evasion;
end

// Count logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        vehiclecount0 <= 0;
        vehiclecount1 <= 0;
        vehiclecount2 <= 0;

        totalrevenue0 <= 0;
        totalrevenue1 <= 0;
        totalrevenue2 <= 0;

        tollrates0 <= 8'd50;
        tollrates1 <= 8'd100;
        tollrates2 <= 8'd150;

        evasioncount <= 0;
    end else begin
        if (reset_counters) begin
            case (vehicle_class)
                2'd0: begin vehiclecount0 <= 0; totalrevenue0 <= 0; end
                2'd1: begin vehiclecount1 <= 0; totalrevenue1 <= 0; end
                2'd2: begin vehiclecount2 <= 0; totalrevenue2 <= 0; end
            endcase
            evasioncount <= 0;
        end

        if (countvehicle) begin
            case (vehicle_class)
                2'd0: vehiclecount0 <= vehiclecount0 + 1;
                2'd1: vehiclecount1 <= vehiclecount1 + 1;
                2'd2: vehiclecount2 <= vehiclecount2 + 1;
            endcase
        end

        if (countrevenue) begin
            case (vehicle_class)
                2'd0: totalrevenue0 <= totalrevenue0 + tollrates0;
                2'd1: totalrevenue1 <= totalrevenue1 + tollrates1;
                2'd2: totalrevenue2 <= totalrevenue2 + tollrates2;
            endcase
        end

        if (logevasion)
            evasioncount <= evasioncount + 1;

        if (updaterate) begin
            case (vehicle_class)
                2'd0: tollrates0 <= rate_input;
                2'd1: tollrates1 <= rate_input;
                2'd2: tollrates2 <= rate_input;
            endcase
        end
    end
end

endmodule
