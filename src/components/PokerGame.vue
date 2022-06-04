<template>
  <div class="container">
    <div class="row my-5">
      <div class="col-1 mx-auto">
        <button v-if="!this.name" @click="this.join" type="button" class="btn btn-primary">Join</button>
        <button v-else-if="this.vote === 0" @click="this.sendVote" type="button" class="btn btn-primary">Vote</button>
        <button v-else-if="this.showVote" @click="this.reset" type="button" class="btn btn-primary">Reset</button>
      </div>
    </div>
    <div class="row my-5" v-if="this.name !== ''">
      <div class="col-6"><h1>Player: {{ this.name }}</h1></div>
      <div class="col-6"><h1>Vote: {{ this.vote }}</h1></div>
    </div>
    <div class="row">
      <h2>Players:</h2>
    </div>
    <div class="row">
      <div v-for="player in players" :key="player.name" class="col-2 border mx-1">
        <p class="text-center">Player: {{ player.name }}</p>
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
      players: []
    }
  },
  created() {
    this.socket = io("http://localhost:3001");
    this.socket.on("newPlayer", data => {
      console.log(data + " joined!");
      if (!this.players.find(el => el.name === data.name)) {
        this.players.push(data);
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
      this.socket.emit("join", this.name);
    }
  },
  watch: {
    name(newName) {
      localStorage.name = newName;
    }
  },
  methods: {
    join() {
      let name = prompt('Input name');
      if (name !== null) {
        this.name = name;
        this.socket.emit("join", name);
      }
    },
    sendVote() {
      let vote = parseInt(prompt('Vote'));
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
