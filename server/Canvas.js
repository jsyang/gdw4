function Canvas() {
    if ( !(this instanceof Canvas) ) {
        return new Canvas();
    }
    this.init();
}


/*
 * Initializes players, can be called anytime to reset all player info.
 */
Canvas.prototype.init = function() {
    this.lines = [];
    this.lineCount = 0; 
}

Canvas.prototype.addLine = function(line) {
    this.lineCount++;
    this.lines.push({ 
        x1: line.x1,
        y1: line.y1,
        x2: line.x2,
        y2: line.y2, 
        createdTime: new Date().getTime()
    });
    console.log('Add line: ' + line);
}

Canvas.prototype.getCanvasData = function() {
    var canvasData = { 
        lines: []
    };
    canvasData.lines = this.lines;
    return this.canvasData = canvasData;
}

module.exports = Canvas();