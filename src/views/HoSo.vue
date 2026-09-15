<template>
  <section class="panel profile-page">

    <div class="title-row">

      <h2>Hồ sơ tài khoản</h2>

      <button class="secondary small" @click="$emit('logout')">
        Đăng xuất
      </button>

    </div>

    <p v-if="notice" class="success-text">
      {{ notice }}
    </p>

    <div class="profile-grid">

      <label>
        Họ và tên

        <input v-model="draft.name">
      </label>

      <label>
        Ngày sinh

        <input v-model="draft.birth" type="date">
      </label>

      <label>
        Giới tính

        <input v-model="draft.gender">
      </label>

      <label>
        Email

        <input v-model="draft.email">
      </label>

      <label>
        Số điện thoại

        <input v-model="draft.phone">
      </label>

      <label class="full">
        Địa chỉ nhận hàng

        <input v-model="draft.address">
      </label>

      <label class="full">
        Tiểu sử

        <textarea v-model="draft.bio"></textarea>
      </label>

    </div>

    <div class="actions profile-actions">

      <button class="primary" @click="save">
        Lưu
      </button>

      <button class="secondary">
        Đổi mật khẩu
      </button>

      <button class="danger" @click="$emit('delete')">
        Xóa tài khoản
      </button>

    </div>
  </section>
</template>

<script setup>
import {
  reactive,
  ref,
  watch
} from 'vue'

const props = defineProps({
  profile: Object
})

const emit = defineEmits([
  'save',
  'logout',
  'delete'
])

const draft = reactive({
  ...props.profile
})

const notice = ref('')

watch(
  () => props.profile,
  (value) => Object.assign(draft, value)
)

function save() {

  emit('save', {
    ...draft
  })

  notice.value =
    'Đã lưu thông tin tài khoản.'
}
</script>