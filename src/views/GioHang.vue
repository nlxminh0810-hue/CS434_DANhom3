<template>
  <section class="panel">
    <div class="title-row"><h2>Giỏ hàng</h2><b>Tổng: {{ money(total) }}</b></div>
    <div class="table-wrap">
      <table>
        <thead><tr><th>Sản phẩm</th><th>Màu</th><th>Size</th><th>Số lượng</th><th>Giá</th><th></th></tr></thead>
        <tbody>
          <tr v-for="item in cart" :key="item.key">
            <td>{{ item.name }}</td><td>{{ item.color }}</td><td>{{ item.size }}</td>
            <td><input class="qty-input" v-model.number="item.qty" type="number" min="1"></td>
            <td>{{ money(item.price) }}</td>
            <td><button class="danger small" @click="$emit('remove', item.key)">Xóa</button></td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-if="!cart.length" class="empty">Giỏ hàng đang trống.</p>
    <button class="primary" :disabled="!cart.length" @click="$emit('checkout')">Thanh toán</button>
  </section>
</template>

<script setup>
import { computed } from 'vue'
import { money } from '../utils/format'
const props = defineProps({ cart: Array })
defineEmits(['remove', 'checkout'])
const total = computed(() => props.cart.reduce((sum, item) => sum + item.price * Number(item.qty || 0), 0))
</script>
