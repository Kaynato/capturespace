// Generated by CoffeeScript 1.10.0
var avec, potato, saltCombine, saltGen, sha256;

sha256 = require('js-sha256');

exports.randColor = function() {
  return (Math.floor(Math.random() * 16777215)) | 0;
};

exports.keygen = function() {};

exports.validate = function(key, hash, salt) {
  var H;
  H = sha256(saltCombine(key, salt));
  return H === hash;
};

saltGen = function() {
  var result, x;
  result = '';
  x = (Math.random() + "").slice(2) + (Math.random() + "").slice(2);
  for (var i = 0; (i+2) < x.length; i++)
		result += String.fromCharCode((9+i) * parseInt(x.slice(i,i+2),16));
  return result;
};

saltCombine = function(S, s) {
  if (S == null) {
    S = "";
  }
  return s.slice(0, 4) + S.slice(0, 3) + s.slice(4, 8) + S.slice(3, 7) + s.slice(8, 12) + S.slice(7, S.length) + s.slice(12, s.length);
};

potato = function(s) {
  var q;
  q = saltGen();
  return [sha256(saltCombine(s, q)), q];
};

exports.playerCoords = function(RS) {
  var R, ang, i, j, k, mag, ref, ref1, results, team;
  if (RS.teams !== 2) {
    throw new Error("Must have exactly 2 teams.");
  }
  if (RS.playersPerTeam === 1) {
    return [[0, 0, RS.radius - RS.PSPAWN], [0, 0, RS.PSPAWN - RS.radius]];
  }
  results = [];
  for (i = j = 0, ref = RS.playersPerTeam - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
    for (team = k = 0, ref1 = RS.teams - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; team = 0 <= ref1 ? ++k : --k) {
      mag = Math.sqrt(RS.PSPAWN * (2 * RS.radius - RS.PSPAWN));
      ang = 2 * Math.PI * ((i + (team / RS.teams)) / RS.playersPerTeam);
      R = avec(mag, ang);
      console.log("R: [" + R + "] || θ: " + ang + " || M: " + mag + " || team " + team);
      R.push(((2 * team - 1) * (RS.radius - RS.PSPAWN)) | 0);
      results.push(R);
    }
  }
  return results;
};

avec = function(mag, ang) {
  return [(mag * Math.cos(ang)) | 0, (mag * Math.sin(ang)) | 0];
};
