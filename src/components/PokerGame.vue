<template>
  <div class="container">
    <div class="row my-5">
      <div class="col-12 text-center">
        <button v-if="!this.joined" @click="this.join" type="button" class="btn btn-primary mx-5">Join</button>
        <button v-if="this.joined" @click="this.leave" type="button" class="btn btn-primary mx-5">Leave</button>
        <button @click="this.reset" type="button" class="btn btn-primary">Reset</button>
      </div>
    </div>
    <div v-if="this.joined && this.vote === 0" class="row my-5">
      <div class="col-2"></div>
      <div class="col-1"><button @click="this.sendVote(1)" type="button" class="btn btn-primary">1</button></div>
      <div class="col-1"><button @click="this.sendVote(2)" type="button" class="btn btn-primary">2</button></div>
      <div class="col-1"><button @click="this.sendVote(3)" type="button" class="btn btn-primary">3</button></div>
      <div class="col-1"><button @click="this.sendVote(4)" type="button" class="btn btn-primary">4</button></div>
      <div class="col-1"><button @click="this.sendVote(5)" type="button" class="btn btn-primary">5</button></div>
      <div class="col-1"><button @click="this.sendVote(6)" type="button" class="btn btn-primary">6</button></div>
      <div class="col-1"><button @click="this.sendVote(7)" type="button" class="btn btn-primary">7</button></div>
      <div class="col-1"><button @click="this.sendVote(8)" type="button" class="btn btn-primary">8</button></div>
      <div class="col-1"><button @click="this.sendVote(9)" type="button" class="btn btn-primary">9</button></div>
      <div class="col-1"><button @click="this.sendVote(10)" type="button" class="btn btn-primary">10</button></div>
    </div>
    <div v-if="this.joined && this.vote === 0" class="row my-5">
      <div class="col-2"></div>
      <div class="col-1"><button @click="this.sendVote(0.5)" type="button" class="btn btn-primary">0.5</button></div>
      <div class="col-1"><button @click="this.sendVote(1)" type="button" class="btn btn-primary">1</button></div>
      <div class="col-1"><button @click="this.sendVote(2)" type="button" class="btn btn-primary">2</button></div>
      <div class="col-1"><button @click="this.sendVote(3)" type="button" class="btn btn-primary">3</button></div>
      <div class="col-1"><button @click="this.sendVote(5)" type="button" class="btn btn-primary">5</button></div>
      <div class="col-1"><button @click="this.sendVote(8)" type="button" class="btn btn-primary">8</button></div>
      <div class="col-1"><button @click="this.sendVote(13)" type="button" class="btn btn-primary">13</button></div>
      <div class="col-1"><button @click="this.sendVote(20)" type="button" class="btn btn-primary">20</button></div>
    </div>
    <div class="row my-5" v-if="this.name !== ''">
      <div class="col-6"><h2>Player: {{ this.name }}</h2></div>
      <div class="col-6"><h2>Vote: {{ this.vote }}</h2></div>
    </div>
    <div class="row my-5" v-if="this.showVote">
      <div class="col-6"><h2>Average: {{ this.average }}</h2></div>
      <div class="col-6"><h2>Median: {{ this.median }}</h2></div>
    </div>
    <div class="row">
      <h2>Players:</h2>
    </div>
    <div class="row">
      <div v-for="player in players" :key="player.name" class="col-2 border mx-1">
        <p class="text-center my-3">Player: {{ player.name }}</p>
        <p v-if="!this.showVote" class="text-center">Voted: {{ player.vote === 0 ? "no" : "yes" }}</p>
        <p v-else class="text-center">Vote: {{ player.vote }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import io from "socket.io-client";

export default {
  data() {
    return {
      name: '',
      vote: 0,
      showVote: false,
      players: [],
      average: 0,
      median: 0,
      joined: false
    }
  },
  created() {
    this.socket = io("https://server.napp.verdanditeam.com");
    this.socket.on("playerJoined", data => {
      console.log(data + " joined!");
      if (!this.players.find(el => el.name === data.name)) {
        this.players.push(data);
      }
    });
    this.socket.on("playerLeft", data => {
      let index = this.players.findIndex(el => el.name === data);
      if (index !== -1) {
        this.players.splice(index, 1);
      }
    });
    this.socket.on("players", data => {
      this.players = data;
      let index = this.players.findIndex(el => el.name === this.name);
      if (index !== -1) {
        this.vote = this.players[index].vote;
      }
    });
    this.socket.on("reveal", data => {
      this.players = data;
      this.showVote = true;

      let avg = 0;
      this.players.forEach(el => { avg += el.vote });
      this.average = Math.round((avg/this.players.length)*10)/10;

      let median = [];
      this.players.forEach(el => { median.push(el.vote) });
      median.sort((a,b) => {
        if (a > b) return 1;
        if (a < b) return -1;
        return 0;
      });
      let center = (median.length-1)/2;
      if (center % 1 !== 0) {
        this.median = Math.floor(((median[Math.floor(center)] + median[Math.ceil(center)])/2)*10)/10;
      } else {
        this.median = median[center];
      }
    });
    this.socket.on("reset", data => {
      this.players = data;
      this.showVote = false;
      this.vote = 0;
      if (this.name !== '') {
        this.socket.emit("join", this.name);
      }
    })
  },
  mounted() {
    if (localStorage.name) {
      this.name = localStorage.name;
      this.players.push(this.name)
      this.joined = true;
      this.socket.emit("join", this.name);
    }
  },
  watch: {
    name(newName) {
      localStorage.name = newName;
    },
    players(newPlayers) {
      this.joined = newPlayers.find(el => el.name === this.name);
    }
  },
  methods: {
    join() {
      let name = null;
      if (this.name !== '') {
        name = this.name;
      } else {
        name = prompt('Input name');
      }
      if (name !== null) {
        this.name = name;
        this.joined = true;
        this.socket.emit("join", name);
      }
    },
    leave() {
      this.joined = false;
      this.socket.emit("leave", this.name);
    },
    sendVote(vote) {
      if (vote !== 0 && !isNaN(vote)) {
        this.vote = vote;
        this.socket.emit("vote", { name: this.name, vote: vote });
      } else {
        alert("wrong vote");
      }
    },
    reset() {
      this.socket.emit("reset");
    }
  }
}
</script>
