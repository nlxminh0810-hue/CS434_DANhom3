<template>
  <header class="header">
    <button class="logo" @click="$emit('navigate', 'home')">

      <div class="logo-icon">
        <i class="bi bi-dribbble"></i>
      </div>

      <b>SoccerHub</b>
    </button>

    <nav class="navbar">
      <button v-for="tab in tabs" :key="tab.id" :class="{ active: page === tab.id }" @click="$emit('navigate', tab.id)">
        {{ tab.name }}
      </button>
    </nav>

    <div class="account-actions">

      <button v-if="!user" class="login-link" @click="$emit('login')">
        Đăng nhập
      </button>

      <button v-if="!user" class="register-link" @click="$emit('register')">
        Đăng ký
      </button>

      <button v-else class="login-link" @click="$emit('navigate', 'profile')">
        {{ user.name }}
      </button>

      <button class="cart" @click="$emit('navigate', 'cart')">
        <i class="bi bi-cart3"></i>

        <span v-if="cartCount">
          {{ cartCount }}
        </span>
      </button>

    </div>
  </header>
</template>

<script setup>
defineProps({
  page: String,
  user: Object,
  cartCount: Number,
  tabs: Array
})

defineEmits([
  'navigate',
  'login',
  'register'
])
</script>