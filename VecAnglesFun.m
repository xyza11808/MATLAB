function ThetaInDegrees = VecAnglesFun(u,v)

CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
ThetaInDegrees = real(acosd(CosTheta));



