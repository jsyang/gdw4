function Chat() {
    if ( !(this instanceof Chat) ) {
        return new Chat();
    }
    this.init();
}


/*
 * Initializes players, can be called anytime to reset all player info.
 */
Chat.prototype.init = function() {
    this.messages = [];
    this.messageCount = 0; 
}

Chat.prototype.sendMessage = function(data) {
    this.messageCount++;
    this.messages.push({ 
        message: data.message,
        name:    data.name
    });
    console.log('Add message: ' + data.message);
}

Chat.prototype.getChatData = function() {
    var ChatData = { 
        messages: []
    };
    ChatData.messages = this.messages;
    return this.ChatData = ChatData;
}

module.exports = Chat();