#include <vector>
#include <stdlib.h>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

enum suit {spade, diamond, heart, club};
//Kings, Queens, Jacks will be considered a 10, a la Blackjack
enum value {ace=1, two=2, three=3, four=4, five=5, six=6, seven=7, eight=8, nine=9, ten=10, jack=10, queen=10, king=10};

vector<suit> suitVector = { spade, diamond, heart, club };
vector<value> valueVector = { ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king};

class Card {
    suit cardSuit;//one of the enum "suit"
    int cardValue;//one of the enum "value"
    
public:
    Card(suit aSuit, value aValue) {
        cardSuit = aSuit;
        cardValue = aValue;
    }
    
    suit getSuit() {
        return cardSuit;
    }
    
    int getValue() {
        return cardValue;
    }
    
};

class Deck {
    //deckCards keeps track of the cards currently in the deck
    //discardCards keeps track of the cards that are *not* in anyone's hands OR the deck
    vector<Card> deckCards, discardCards;
    
public:
    Deck() {//deck does not get shuffled upon creation. Rather, drawing always draws randomly
        for (int i = 0; i < suitVector.size(); i++) {
            for (int j = 0; j < valueVector.size(); j++) {
                deckCards.push_back(Card(suitVector[i], valueVector[j]));
            }
        }
    }
    
    Card RemoveCard(int index) {
        Card removedCard = deckCards[index];
        deckCards.erase(deckCards.begin() + index);
        return removedCard;
    }
    
    Card DrawCard() {
        int ranPick = rand() % deckCards.size();
        return RemoveCard(ranPick);
    }
    
    void DiscardCard(Card toDiscard) {
        discardCards.push_back(toDiscard);
    }
};

class Player {
    string name;
    vector<Card> handCards;
    
public:
    Player(string aName) {
        name = aName;
    }

    void AddCard(Card newcard) {
        handCards.push_back(newcard);
    }
    
    string getName() {
        return name;
    }

    int getScore() {
        int totalScore = 0;
        for (int i = 0; i < handCards.size(); i++) {
            totalScore += handCards[i].getValue();
        }
        return totalScore;
    }
};

string dealCount(Deck deck, vector<Player> players) {    
    if (players.size() < 11) {
        string bestName = "Larry";
        int bestScore = 0;
        for (int i = 0; i < players.size(); i++) {
            for (int j = 0; j < 5; j++) {
                players[i].AddCard(deck.DrawCard());
            }
            int totalScore = players[i].getScore();
            if (totalScore > bestScore) {
                bestScore = totalScore;
                bestName = players[i].getName();
            }
        }
        return "The best score was " + to_string(bestScore) + ", by " + bestName + "!";
    } else {
       return "Too many players. Please get fewer friends. (10 or less.)";
    } 
}

int main() {
    return 0;
}
