#version 400

uniform vec2 RES;
uniform float FOV_DIST;
uniform vec3 CAM_POS;
uniform vec4 CAM_ROT;
uniform float STEP;
uniform int ITER;
uniform float GRAV;
uniform sampler2D DISC_TEX;
uniform sampler2D SKY_TEX;
uniform float DISC_ROT;

out vec4 COLOR;

mat2x3 f(mat2x3 x, float h2) {
    mat2x3 res;
    res[0] = x[1];
    res[1] = -1.5 * GRAV * h2 * x[0] / pow(length(x[0]), 5);
    return res;
}

vec4 raytrace(vec2 pixel) {
    vec3 pos = CAM_POS;
    vec3 vel = normalize(vec3(pixel.x, pixel.y, FOV_DIST));
    vel += 2*cross(CAM_ROT.xyz, cross(CAM_ROT.xyz, vel) + CAM_ROT.w*vel);
    float h2 = pow(length(cross(pos, vel)), 2);
    float alpha = 0.1;
    for (int i = 0; i < ITER; i++) {
        mat2x3 state;
        state[0] = pos;
        state[1] = vel;
        mat2x3 k1 = f(state,               h2);
        mat2x3 k2 = f(state + 0.5*STEP*k1, h2);
        mat2x3 k3 = f(state + 0.5*STEP*k2, h2);
        mat2x3 k4 = f(state +     STEP*k3, h2);
        mat2x3 inc = (STEP / 6.0)*(k1 + 2*k2 + 2*k3 + k4);
        vel += inc[1];
        vec3 oldPos = pos;
        pos += inc[0];
        if (length(pos) < 1) {
            //return vec4(1-alpha, 1-alpha, 1-alpha, 1.0);
            return vec4(1,1,1,1)-vec4(1-alpha, 1-alpha, 1-alpha, 0.0);
        }
        else if (length(pos) > 15) {
            vec2 loc = vec2(atan(pos.x-CAM_POS.x, pos.z-CAM_POS.z) * 0.5 / 3.1415926 + 0.5, 
                            atan(pos.y-CAM_POS.y, length(pos.xz-CAM_POS.xz)) / 3.1415926 + 0.5);
            vec4 pixel = texture2D(SKY_TEX, loc);
            //return vec4(pixel.x-alpha, pixel.y-alpha, pixel.z-alpha, 1.0);
            return vec4(1,1,1,1)-vec4(pixel.x-alpha, pixel.y-alpha, pixel.z-alpha, 0.0);
        }
        else if (pos.y*oldPos.y < 0) {
            vec3 isc = oldPos + vel * (-oldPos.y/vel.y);
            if ((length(isc.xz) > 3) && (length(isc.xz) < 9)) {
                float lat = atan(isc.x, isc.z) * 0.5 / 3.1415926 + 0.5 - DISC_ROT;
                while (lat < 0) lat += 1;
                vec2 loc = vec2(lat, (length(isc.xz)-3) / 6);
                vec4 pixel = texture2D(DISC_TEX, loc);
                alpha += pixel.x * (1-1/(1+exp(-2*(length(isc.xz)-7))));
            }
        }
    }
    return vec4(1.0, 0.0, 1.0, 1.0);
}

void main() {
    vec2 scr = vec2((gl_FragCoord.x*2 - RES.x) / RES.x, (RES.y-gl_FragCoord.y*2) / RES.x)/* - vec2(0.5, 0.5)*/;
    COLOR = raytrace(scr);
}