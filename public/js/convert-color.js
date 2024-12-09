// from: https://stackoverflow.com/questions/11866781/how-do-i-convert-an-integer-to-a-javascript-color

intToRGB = (num) => {
    num >>>= 0;
    var b = num & 0xFF,
        g = (num & 0xFF00) >>> 8,
        r = (num & 0xFF0000) >>> 16;
    return "rgba(" + [r, g, b].join(",") + ")";
}

intToHexColor = (num) => {
    return "#" + num.toString(16).padStart(6, "0");
}