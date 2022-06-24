// freeScale by Vaporware
// Remixed from iRuler by DrLex; Based on customizable ruler by Stu121.
// License: Creative Commons - Attribution - Share Alike
// 2017-04-21: v2: added inches option
// 2021-12-11: v3: added dual units & rounded corners; dropped shrinkage compensation (it makes more sense to always generate 1:1 models and let the user do the scaling in their slicer)
// 2022-06-16 remix to add Scale
//assert(version() == [2019, 5, 0]);
assert(ord(" ") == 32);
assert(ord("\x00") == 32);
assert(ord("\u0000") == 32);
assert(ord("\U000000") == 32);
 
/* [General] */
//Select Primary Edge Scale. scaleM is scale Meters. both will add CM to secondary edge
Units="both"; //[centimeters, inches, scaleM, both]
//Select Primary Edge when Units = both
Units2="centimeters";//[centimeters, inches, scaleM]
// Length of the Rule. When Units = 'both' and Units2 = "inches", this length is in inches.
RulerLength=24.2; //[1:50]
RulerWidth=50; //[20:1:50]
//Check Zero at Edge to have the ruler edge at 0
ZeroAtEdge=true;//[true,false]
WithHole="yes"; //[yes, no]
ReverseDesign="no"; //[yes, no]
// If nonzero, round corners with this radius
RoundCorners=0; //[0:.5:5]

/* [Scaling] */
ScaleNum = 1; //Scale Numerator
ScaleDenom = 87.1; //Scale Denominator
ScalingFactor = (ScaleNum/ScaleDenom>=1)? ScaleDenom/ScaleNum : ScaleNum/ScaleDenom;//ScalingFactor
ScaleTxt = str(ScaleNum,":",ScaleDenom);

/* [Text] */
RulerText="FreeScale";
FontSize=10; //[3:.5:14]
BoldFont="no"; //[yes, no]
NarrowFont="no"; //[yes, no]
TextHeight=1; //[-2.6:.1:5]
TextX=80;
TextY=0; //[-10:.5:10]

/* [Numbers] */
NumberSize=5; //[1:15]
BoldNumbers="no"; //[yes, no]
NumberHeight=.5; //[-2.6:.1:5]
NumberOffset=0; //[-2:.5:2]
ScaleTxtOffset=6; //[-25:.25:25]
ScaleTxtSize=4; //[1:15]

/* [Ruler lines] */
UnitsLineWidth=.6; //[.3:.05:.7]
SubdivisionsGapWidth=.3; //[.2:.05:.5]

/* [Export Options] */
//WARNING: CAN BE SLOW! To Export a SVG for laser cutting: set NumberHeight to -2.6, set TextHeight to -2.6, and THEN check this box
SVG_export = false; //[true,false]

/* [Hidden] */
scaleLength = (((Units == "inches") || (Units == "both" && Units2 == "inches")) ? RulerLength*25.4 : RulerLength*10);
rulerLength2 = floor(scaleLength/10);
shift2 = ReverseDesign == "yes" ? 0 : scaleLength - rulerLength2*10;
Font= NarrowFont == "no" ? "Roboto" : "Roboto Condensed";
Font2="Roboto Condensed";
Hole=(WithHole == "yes");
Inverted=(ReverseDesign == "yes");
TextFont = BoldFont == "no" ? Font : str(Font, ":style=Bold");
NumberFont = BoldNumbers == "no" ? Font2 : str(Font2, ":style=Bold");
textCenterY = (Units == "both") ? RulerWidth/2 - 5 : RulerWidth/2 + 3;
EdgePadX = (ZeroAtEdge?0:5);

Diaclone = "\u30C0\u30A4\u30A2\u30AF\u30ED\u30F3";
GIJoe = "GI\u272FJOE\u2261";
echo(Diaclone);


module unitLines(unit, length) {
    uSize = ((unit == "scaleM") ? (1000 * ScalingFactor) :   //if scale then set uSize to scaled
            (unit == "inches" ? 25.4 : 10));
    
    uLength = ((unit == "scaleM") ? (length / (100 * ScalingFactor)):length); //i.e. 20cm ruler(length) at 1/60 scale is 12m and and has 12 division lines
    uStart = ((uLength<=25)?1:5);
    uStep = ((uLength<=25)?1:(uLength<=150)?5:10);
    uStop = uLength;
        
    //echo("unit ", unit, " length ", length, " uLength ", uLength);
    
    for (i=[uStart:uStep:uStop]) {
        translate([i*uSize-UnitsLineWidth/2,-4.9,0.6]) rotate([8.5,0,0]) cube([UnitsLineWidth,10,.7]);
    }
}
module makeMetricSubdivision(i, uSize, GapLength) {
    translate([i*uSize-SubdivisionsGapWidth/2,-4.95,(SVG_export?-2:0.5)])
    rotate([8.5,0,0])
    cube([SubdivisionsGapWidth,GapLength,(SVG_export?7:0.7)]);
}
module makeImpSubdivision(length) {
    for (i=[0:length-1]) {
        translate([(i+0.5)*25.4-SubdivisionsGapWidth/2,-4.95,0.5])
        rotate([8.5,0,0])
        cube([SubdivisionsGapWidth,8,.7]);
            for (j=[0:1]) {
                translate([(i+0.25+j*0.5)*25.4-SubdivisionsGapWidth/2,-4.95,0.5])
                rotate([8.5,0,0])
                cube([SubdivisionsGapWidth,6,.7]);
            }
            for (j=[0:3]) {
                translate([(i+0.125+j*0.25)*25.4-SubdivisionsGapWidth/2,-4.95,0.5])
                rotate([8.5,0,0])
                cube([SubdivisionsGapWidth,4.25,.7]);
            }
            for (j=[0:7]) {
                translate([(i+0.0625+j*0.125)*25.4-SubdivisionsGapWidth/2,-4.95,0.5])
                rotate([8.5,0,0])
                cube([SubdivisionsGapWidth,2.5,.7]);
            }
        }
}
module subdivisions(unit, length) {
    //Subdivision lines. These are recessed to improve printability with thicker nozzles.
    length = length;
    uSize = ((unit == "scaleM") ? (1000 * ScalingFactor) :   
            (unit == "inches" ? 25.4 : 10))/10;
    uLength = ((unit == "scaleM") ? (length / (100 * ScalingFactor)):length); //i.e. 20cm ruler(length) at 1/60 scale is 12m and and has 12 division lines
    uStart = 0;//((uLength<=5)?0.5:(uLength<=25)?1:5);
    uStep = ((uLength<=5)?0.5:(uLength<=35)?1:(uLength<=150)?5:10);
    uStop = uLength*10;

    //echo("unit ", unit, " length ", length, " uLength ", uLength);
    
    if(unit == "centimeters"||unit == "scaleM") {
        
        for (i=[uStart:uStep:uStop]) {
            if(i % (SVG_export?0:100)) {
                
                isEven = (i%2)==0;
                
                if (isEven) {
                    GapLength=((i%10)? 3.5 : 10);     //Even subminor length: minor length
                    makeMetricSubdivision(i, uSize, GapLength);

                }
                else{
                    GapLength=((i%5)? 5 : 6.5);        //Odd subminor length: minor length
                    makeMetricSubdivision(i, uSize, GapLength);
                }                
            }
        }
    }
    else {
        makeImpSubdivision(length);
    }
}

module numbers(unit, length, reverse) {
    uSize = ((unit == "scaleM") ? (1000 * ScalingFactor) :   //if scale then set uSize to scaled else: 
            (unit == "inches" ? 25.4 : 10));                //inches and CM
    
    uLength = ((unit == "scaleM") ? (length / (100 * ScalingFactor)):length); //i.e. 20cm ruler(length) at 1/60 scale is 12m and and has 12 division lines
    unitText = ((unit == "scaleM") ? str(ScaleTxt, "m") :
             (unit == "inches" ? "IN" : "CM"));

    uStart = ((uLength<=25)?1:5);
    uStep = ((uLength<=25)?1:(uLength<=150)?5:10);
    uStop = (ZeroAtEdge?uLength-1:uLength);
    
    echo("unit ", unit, " length ", length, " uLength ", uLength);
    
    Thickness=abs(NumberHeight) + (NumberHeight < 0 ? 0.1 : 0);
    ZPos=NumberHeight >= 0 ? 2.5 : 2.5+NumberHeight;
    Rot=reverse ? [0,0,180] : [0,0,0];
    RotCenter=[uLength*uSize/2, 5.5+NumberSize/2, 0];
    translate(RotCenter) rotate(Rot) {
        for (i=[uStart:uStep:uStop]) {
            //NumberOffsetActual=(i > 9) ? NumberOffset-2.5 : NumberOffset;
            translate([(i*uSize)+NumberOffset,5.5,ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
            text(
                        //((uLength<=25)&&(unit == "scaleM"))?((i%10)?str(i):str(i,"m")):str(i),
                        str(i),
                        ((i<100)?NumberSize:(NumberSize-1)),
                        font=NumberFont,
                        halign="center",
                        spacing = ((i<100)?1:0.75),$fn=24);
        }
        
        translate([0,5.5+(reverse? -1*ScaleTxtOffset:ScaleTxtOffset),ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
            text(unitText,ScaleTxtSize,font=NumberFont,halign="left",$fn=24);
    }
}

module label() {
    //uSize = unit == "inches" ? 25.4 : (1000 * ScalingFactor);
    
    //uLength = (length / (100 * ScalingFactor));
    
    Thickness=abs(TextHeight) + (TextHeight < 0 ? 0.1 : 0);
    ZPos=TextHeight >= 0 ? 2.5 : 2.5+TextHeight;
    Rot=Inverted ? [0,0,180] : [0,0,0];
    RotCenter=[scaleLength/2+5,TextY,0];
    translate(RotCenter) rotate(Rot) {
        translate([TextX,TextY,ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
            text(RulerText,FontSize,font=TextFont,valign="center",$fn=24);
    }
}


module createRule(){
//Body - Intersect Rule with Corners
intersection() {
    //Body - Difference Rule and Subdivision Lines
    difference() {
        union() {
            //Extrude Primary Edge Body
            top_width = RulerWidth - (Units == "both" ? 20 : 10);
            hull() {
                translate([0,5,0])   cube([scaleLength+2*EdgePadX,top_width,2.5]);
                translate([0,-5,0])  cube([scaleLength+2*EdgePadX,RulerWidth,1]);
            }
            
            //Extrude Unit Lines (major divisions) & Numbers
            translate([EdgePadX,0,0]) {
                if(Units != "both") {
                    unitLines(Units, RulerLength);
                    if(NumberHeight > 0) {
                        numbers(Units, RulerLength, Inverted);
                    }
                }
                else {
                    unitLines(Units2, RulerLength);
                    //echo(Units2);
                    if(NumberHeight > 0) {
                        numbers(Units2, RulerLength, Inverted);
                    }
                    rotate([0,0,180]) translate([-scaleLength+shift2,-RulerWidth+10,0]) {
                        unitLines("centimeters", rulerLength2);
                        if(NumberHeight > 0) {
                            numbers("centimeters", rulerLength2, !Inverted);
                        }
                    }
                }
            }
    
            //Extrude Label Text
            if (TextHeight > 0 && RulerText != "") {
                translate([0,textCenterY,0]) label();
            }
        }
        //Cut Subdivision Lines (minor divisions)
        translate([EdgePadX,0,0]) {
            if(Units != "both") {
                subdivisions(Units, RulerLength);
                if (NumberHeight < 0) {
                    numbers(Units, RulerLength, Inverted);
                }
            }
            else {
                subdivisions(Units2, RulerLength);
                if (NumberHeight < 0) {
                    numbers(Units2, RulerLength, false);
                }
                rotate([0,0,180]) translate([-scaleLength+shift2,-RulerWidth+10,0]) {
                    subdivisions("centimeters", rulerLength2);
                    if (NumberHeight < 0) {
                        numbers("centimeters", rulerLength2, !Inverted);
                    }
                }
            }
        }
    
        if (TextHeight < 0 && RulerText != "") {
            translate([0,textCenterY,0]) label();
        }
        if (Hole) {
            EdgePadX = ((ZeroAtEdge)?10:0);
            holeX = Inverted ? 10 : (scaleLength-EdgePadX);
            holeY = (Units == "both") ? RulerWidth/2 - 5 : RulerWidth/2;
            translate([holeX,holeY,2])  cylinder(10, 2.5, 2.5, center=true, $fn=16);
        }
    
    }
    
    if(RoundCorners > 0) {
        hull() {
            translate([RoundCorners,-5+RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=16);
            translate([RoundCorners,RulerWidth-5-RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=24);
            translate([scaleLength+2*EdgePadX-RoundCorners,-5+RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=24);
            translate([scaleLength+2*EdgePadX-RoundCorners,RulerWidth-5-RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=16);
    
        }
    
    }
}
}

if(SVG_export == true) {
    
    

    projection() {
        //translate([0,0,0])
        createRule();
    }
}
else {
        createRule();
}