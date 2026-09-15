<template>
  <section class="auth-page">
    <form class="auth-card" @submit.prevent="submit">
      <p class="label">Khôi phục tài khoản</p>
      <h2>Quên mật khẩu</h2>
      <p class="auth-note">Nhập email hoặc số điện thoại để mô phỏng đặt lại mật khẩu.</p>
      <label>Email hoặc số điện thoại<input v-model.trim="account" placeholder="long@soccerhub.vn"></label>
      <label>Mật khẩu mới<input v-model="password" type="password" placeholder="Tối thiểu 6 ký tự"></label>
      <p v-if="error" class="error-text">{{ error }}</p>
      <p v-if="done" class="success-text">Đặt lại mật khẩu thành công.</p>
      <button class="primary">Đặt lại mật khẩu</button>
      <button class="secondary" type="button" @click="$emit('login')">Quay lại đăng nhập</button>
    </form>
  </section>
</template>

<script setup>
import { ref } from 'vue'
defineEmits(['login'])
const account = ref('')
const password = ref('')
const error = ref('')
const done = ref(false)

function submit() {
  error.value = ''
  done.value = false
  if (!account.value || password.value.length < 6) {
    error.value = 'Vui lòng nhập tài khoản và mật khẩu mới tối thiểu 6 ký tự.'
    return
  }
  done.value = true
}
</script>
