var MAX_NAME_LENGTH = 22;

/*
 * Keeps track of players, including names, points, etc.
 *
 * @return {Object} players object
 */
function Players() {
    if ( !(this instanceof Players) ) {
        return new Players();
    }
    this.init();
}


/*
 * Initializes players, can be called anytime to reset all player info.
 */
Players.prototype.init = function() {
    this.players = {};
    this.playerCount = 0; // count of total players joined, not active players
    this.activePlayerCount = 0; // count of players currently connected
    this.winningSocket = null;
    this.drawingSocket = null;
    this.words = [];
    this.winningWords = [];
    this.winnnerName = null;
    
}



Players.prototype.setWords = function(wordlist) {
    var newwords = [];
    for (var i = 0; i < wordlist.length; i++) {
      newwords.push({
            word:    wordlist[i],
            guessed: false
      })
    }
    this.words = newwords;
}

Players.prototype.setWinningWords = function(wordlist) {
    this.winningWords = wordlist;
}

Players.prototype.playerHasGuesses = function (playerId) {
   if (this.players[playerId].guessedWords.length < 2) {
	   return true;
   }
   console.log(playerId+": is out of guesses!");
   return false;
}

Players.prototype.wordNotGuessed = function (checkword) {
   for (var i = 0; i < this.words.length; i++) {
     if (this.words[i].word == checkword && !this.words[i].guessed) {
       return true;
     } 
   }
   console.log(checkword+": word not found or already guessed");
   return false;
}

Players.prototype.markWordGuessed = function (playerId, checkword) {

   this.players[playerId].guessedWords.push(checkword);
   
   for (var i = 0; i < this.words.length; i++) {
     if (this.words[i].word == checkword) {
       this.words[i].guessed = true;     
     } 
     
   }
}

Players.prototype.guessWord = function(data, playerId) {

    if(this.playerHasGuesses(playerId) && this.wordNotGuessed(data.word)){
        this.markWordGuessed(playerId, data.word);
        return true;
    }
   
    return false;
}

Players.prototype.roundIsOver = function() {

  var guessedWord1 = false;
  var guessedWord2 = false;

  //round is over if bother winning words are guessed
  for (var i = 0; i < this.words.length; i++) {
     if (this.words[i].word == this.winningWords[0] && this.words[i].guessed) {
       guessedWord1 = true;    
     }
     
     if (this.words[i].word == this.winningWords[1] && this.words[i].guessed) {
       guessedWord2 = true;    
     } 
     
   }
   
   if(guessedWord1 && guessedWord2) {
       console.log("The round is over");
	   return true;
   }
   return false;
  

}

/*
 * Adds a player. Only name and id required
 *
 * @param {Object} player data, must contain 'name' and 'playerId'. 
 *        if playerId is a duplicate of existing player, old player name is replaced.
 * @return {Object} players object
 */
Players.prototype.addPlayer = function(player) {
    this.playerCount++;
    this.players[player.playerId] = {
        playerId: player.playerId,
        createdTime: new Date().getTime(),
        lastActiveTime: new Date().getTime(),
        lastWinTime: 0,
        clientIp: player.clientIp || '',
        points: 0,
        origName: player.name,
        name: this.normalizePlayerName(player.name) || 'Player_' + this.playerCount,
        role:	"g",
        guessedWords:	[]
    }
    return this.players[player.playerId];
}


/*
 * Removes player. 
 *
 * @param {String|Number} playerId is unique id of player
 */
Players.prototype.removePlayer = function(playerId) {
    delete this.players[playerId];
}


/*
 * Gets player object
 *
 * @param {String|Number} playerId is unique id of player
 * @return {Object} players object
 */
Players.prototype.getPlayer = function(playerId) {
    return this.players[playerId];
}

/*
 * Gets player name
 *
 * @param {String|Number} playerId is unique id of player
 * @return {String} name of player, empty string if player not found
 */
Players.prototype.getPlayerName = function(playerId) {
    return this.players[playerId] ? this.players[playerId].name : '';
}


/*
 * Gets points of player
 *
 * @param {String|Number} playerId is unique id of player
 * @return {Number} points of player, -1 if player is not found
 */
Players.prototype.getPlayerPoints = function(playerId) {
    return this.players[playerId] ? this.players[playerId].points : -1;
}


/*
 * Adds points to a player
 *
 * @param {String|Number} playerId is unique id of player
 * @param {Number} points to add
 * @return {Number} points of player after adding, -1 if player not found
 */
Players.prototype.addPlayerPoints = function(playerId, points) {
    if (!this.players[playerId]) {
        return -1;
    }
    this.players[playerId].points += points;
    this.players[playerId].lastWinTime = new Date().getTime();
    return this.getPlayerPoints(playerId);
}


/*
 * updates player activity time
 *
 * @param {Object|Boolean} returns player object or false if playerId is not found
 */
Players.prototype.lastActive = function(playerId) {
    if (!this.players[playerId]) {
        return false;
    }
    this.players[playerId].lastActiveTime = new Date().getTime();
    return this.players[playerId];
}


/*
 * Returns total number of players added.
 *
 * @return {Number} total number of players added
 */
Players.prototype.getPlayerCount = function() {
    return this.playerCount;
}


/*
 * Used to validate players answer
 
 *
 * @param {Object} data must contain question string and answer string
 * @return {Boolean} true if data matches last question
 */
Players.prototype.getPlayerData = function() {
    var playerData = { 
        players: [],
        words:			this.words,
        winningWords:	this.winningWords
        
    };
    for (var playerId in this.players){
        playerData.players.push({
            createdTime:    this.players[playerId].createdTime,
            lastActiveTime: this.players[playerId].lastActiveTime,
            lastWinTime:    this.players[playerId].lastWinTime,
            points:         this.players[playerId].points,
            name:           this.players[playerId].name,
            role:		    this.players[playerId].role,
            guessesRemaining:	this.players[playerId].guessesRemaining
        });
    }
    playerData.players.sort(function(a,b) {
        return b.points - a.points || a.name > b.name;
    });
    return this.playerData = playerData;
}


/*
 * Used to normalize players name. Only alphanumeric and _ are allowed,
 * and strings are limited to MAX_NAME_LENGTH
 *
 * @param {String} name to normalize
 * @return {String} name after normalizing
 */
Players.prototype.normalizePlayerName = function(name) {
    name = name || '';
    name = name.trim().replace(/\s+/g,'_');
    name = name.replace(/\W/g,'');
    if (name.length > MAX_NAME_LENGTH) {
        name = name.substring(0,MAX_NAME_LENGTH-1) + '_';
    }
    return name;
}


module.exports = Players();