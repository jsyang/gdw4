function Canvas() {
    if ( !(this instanceof Canvas) ) {
        return new Players();
    }
    this.init();
}


/*
 * Initializes players, can be called anytime to reset all player info.
 */
Canvas.prototype.init = function() {
    this.lines = {};
    this.lineCount = 0; 
}

Players.prototype.addLine = function(line) {
    this.lineCount++;
    this.lines[] = {
        x1: line.x1;
        y1: line.y1;
        x2: line.
        createdTime: new Date().getTime(),
        lastActiveTime: new Date().getTime(),
        lastWinTime: 0,
        clientIp: player.clientIp || '',
        points: 0,
        origName: player.name,
        name: this.normalizePlayerName(player.name) || 'Player_' + this.playerCount
    }
    return this.players[player.playerId];
}

