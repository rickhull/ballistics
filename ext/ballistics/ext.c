#include <ruby.h>
#include <gnu_ballistics.h>
VALUE method_zero_angle(VALUE self, VALUE drag_function, VALUE drag_coefficient, VALUE velocity, VALUE sight_height, VALUE zero_range, VALUE y_intercept);
VALUE method_trajectory(VALUE self, VALUE drag_function, VALUE drag_coefficient, VALUE velocity, VALUE sight_height, VALUE shooting_angle, VALUE zero_angle, VALUE wind_speed, VALUE wind_angle, VALUE max_range, VALUE interval);

VALUE cBallistics;
VALUE cExt;
void Init_ext() {
  cBallistics = rb_define_module("Ballistics");
  cExt = rb_define_module_under(cBallistics, "Ext");
  rb_define_singleton_method(cExt, "zero_angle", method_zero_angle, 6);
  rb_define_singleton_method(cExt, "trajectory", method_trajectory, 10);
}

VALUE method_zero_angle(VALUE self, VALUE drag_function, VALUE drag_coefficient, VALUE velocity, VALUE sight_height, VALUE zero_range, VALUE y_intercept) {
  double angle =  ZeroAngle(FIX2INT(drag_function), NUM2DBL(drag_coefficient), NUM2DBL(velocity), NUM2DBL(sight_height), NUM2DBL(zero_range), NUM2DBL(y_intercept));
  return rb_float_new(angle);
}

VALUE method_trajectory(VALUE self, VALUE drag_function, VALUE drag_coefficient, VALUE velocity, VALUE sight_height, VALUE shooting_angle, VALUE zero_angle, VALUE wind_speed, VALUE wind_angle, VALUE max_range, VALUE interval) {

  /* cast ruby variables */
  int    DragFunction = FIX2INT(drag_function);
  double DragCoefficient = NUM2DBL(drag_coefficient);
  double Vi = NUM2DBL(velocity);
  double SightHeight = NUM2DBL(sight_height);
  double ShootingAngle = NUM2DBL(shooting_angle);
  double ZAngle = NUM2DBL(zero_angle);
  double WindSpeed = NUM2DBL(wind_speed);
  double WindAngle = NUM2DBL(wind_angle);
  int    MaxRange = FIX2INT(max_range);
  int    Interval = FIX2INT(interval);

  /* create ruby objects */
  VALUE result_array = rb_ary_new2(MaxRange);


  double t=0;
  double dt=0.5/Vi;
  double v=0;
  double vx=0, vx1=0, vy=0, vy1=0;
  double dv=0, dvx=0, dvy=0;
  double x=0, y=0;

  double headwind=HeadWind(WindSpeed, WindAngle);
  double crosswind=CrossWind(WindSpeed, WindAngle);

  double Gy=GRAVITY*cos(DegtoRad((ShootingAngle + ZAngle)));
  double Gx=GRAVITY*sin(DegtoRad((ShootingAngle + ZAngle)));

  vx=Vi*cos(DegtoRad(ZAngle));
  vy=Vi*sin(DegtoRad(ZAngle));

  y=-SightHeight/12;


  int n=0;
  for (t=0;;t=t+dt){

    vx1=vx, vy1=vy;
    v=pow(pow(vx,2)+pow(vy,2),0.5);
    dt=0.5/v;

    // Compute acceleration using the drag function retardation
    dv = retard(DragFunction,DragCoefficient,v+headwind);
    dvx = -(vx/v)*dv;
    dvy = -(vy/v)*dv;

    // Compute velocity, including the resolved gravity vectors.
    vx=vx + dt*dvx + dt*Gx;
    vy=vy + dt*dvy + dt*Gy;



    int yards = (x/3);
    if (yards>=n){
      if (yards % Interval == 0){
	VALUE entry = rb_hash_new();
	double windage_value = Windage(crosswind,Vi,x,t+dt);
	double moa_windage_value = windage_value / ((yards / 100.0) * 1.0465);
	rb_hash_aset(entry, rb_str_new2("range"), rb_float_new((int)(yards)));
	rb_hash_aset(entry, rb_str_new2("path"), rb_float_new(y*12));
	rb_hash_aset(entry, rb_str_new2("moa_correction"), rb_float_new(-RadtoMOA(atan(y/x))));
	rb_hash_aset(entry, rb_str_new2("time"), rb_float_new(t+dt));
	rb_hash_aset(entry, rb_str_new2("windage"), rb_float_new(windage_value));
	rb_hash_aset(entry, rb_str_new2("moa_windage"), rb_float_new(moa_windage_value));
	rb_hash_aset(entry, rb_str_new2("velocity"), rb_float_new(v));
	rb_ary_push(result_array, entry);
      }
      n++;
    }

    // Compute position based on average velocity.
    x=x+dt*(vx+vx1)/2;
    y=y+dt*(vy+vy1)/2;

    if (fabs(vy)>fabs(3*vx)) break;
    if (n>=MaxRange+1) break;
  }

  return result_array;
}
