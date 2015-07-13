

vec2 nrm = _geometry.position.xz;
float len = length(nrm)+0.0001;
nrm /= len;
float a = len + 0.2*sin(5.0 * _geometry.position.y + u_time * 10.0);
_geometry.position.xz = nrm * a;