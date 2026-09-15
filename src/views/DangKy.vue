<template>
  <section class="auth-page">

    <form
      class="auth-card register-card"
      @submit.prevent="submit"
    >

      <div class="auth-top">

        <h2>Tạo tài khoản mới</h2>

        <button
          class="close-auth"
          type="button"
          @click="$emit('navigate', 'home')"
        >
          <i class="bi bi-x-lg"></i>
        </button>

      </div>

      <div class="register-form-body">

        <input
          class="login-input"
          v-model.trim="form.name"
          placeholder="Nhập tên đăng nhập"
        >

        <input
          class="login-input"
          v-model.trim="form.phone"
          placeholder="Nhập số điện thoại"
        >

        <input
          class="login-input"
          v-model="form.password"
          type="password"
          placeholder="Nhập mật khẩu"
        >

        <input
          class="login-input"
          v-model="form.confirmPassword"
          type="password"
          placeholder="Xác nhận lại mật khẩu"
        >

        <p class="register-text">

          Đã có tài khoản?

          <button
            type="button"
            @click="$emit('login')"
          >
            Đăng nhập
          </button>

        </p>

        <p
          v-if="error"
          class="error-text"
        >
          {{ error }}
        </p>

        <button class="login-submit">
          Đăng kí
        </button>

        <button
          class="social-btn google-btn"
          type="button"
          @click="$emit('social', 'Google')"
        >

          <span class="social-icon">
            <i class="bi bi-google"></i>
          </span>

          <span>
            Tiếp tục với Google
          </span>

        </button>

        <button
          class="social-btn facebook-btn"
          type="button"
          @click="$emit('social', 'Facebook')"
        >

          <span class="social-icon">
            <i class="bi bi-facebook"></i>
          </span>

          <span>
            Tiếp tục với Facebook
          </span>

        </button>

        <button
          class="social-btn phone-btn"
          type="button"
          @click="phoneRegister"
        >

          <span class="social-icon">
            <i class="bi bi-telephone-fill"></i>
          </span>

          <span>
            Tiếp tục với Phone
          </span>

        </button>

      </div>
    </form>
  </section>
</template>

<script setup>
import {
  reactive,
  ref
} from 'vue'

const emit = defineEmits([
  'submit',
  'social',
  'login',
  'navigate'
])

const form = reactive({

  name: '',

  phone: '',

  password: '',

  confirmPassword: ''
})

const error = ref('')

function submit() {

  error.value = ''

  if (
    !form.name ||
    !form.phone ||
    !form.password ||
    !form.confirmPassword
  ) {

    error.value =
      'Vui lòng nhập đầy đủ thông tin.'

    return
  }

  if (form.password.length < 6) {

    error.value =
      'Mật khẩu cần tối thiểu 6 ký tự.'

    return
  }

  if (
    form.password !==
    form.confirmPassword
  ) {

    error.value =
      'Mật khẩu xác nhận chưa khớp.'

    return
  }

  // USER MẶC ĐỊNH
  emit('submit', {

    id: Date.now(),

    username: form.name,

    password: form.password,

    role: 'user',

    name: form.name,

    phone: form.phone,

    birth: '--/--/----',

    created:
      new Date()
      .toLocaleDateString('vi-VN'),

    orders: 0,

    locked: false
  })
}

function phoneRegister() {

  emit('submit', {

    id: Date.now(),

    username:
      form.name || 'phoneuser',

    password: '123456',

    role: 'user',

    name:
      form.name || 'Phone User',

    phone:
      form.phone || '0900000000',

    birth: '--/--/----',

    created:
      new Date()
      .toLocaleDateString('vi-VN'),

    orders: 0,

    locked: false
  })
}
</script>