<template>
  <section class="panel user-order-page">
    <div class="user-order-header">
      <h2>Đơn hàng của tôi</h2>

      <input
        v-model="keyword"
        class="user-order-search"
        placeholder="Nhập mã đơn hàng"
      >
    </div>

    <div class="user-order-list">
      <article
        v-for="item in filteredOrders"
        :key="item.code"
        class="user-order-card"
      >
        <div class="order-top">
          <div class="order-code">
            <b>Mã đơn:</b>
            <span>{{ item.code }}</span>
          </div>

          <div class="order-delivery">
            <b>Giao hàng:</b>
            <span>{{ item.delivery }}</span>
          </div>

          <div class="order-status">
            <b>Trạng thái:</b>
            <span
              class="status-badge"
              :class="statusClass(item.status)"
            >
              {{ item.status }}
            </span>
          </div>

          <div class="order-total">
            <b>Thành tiền:</b>
            <span>{{ money(item.total) }}</span>
          </div>
        </div>

        <div class="order-product">
          <b>Sản phẩm:</b>
          <p>{{ item.product }}</p>
        </div>

        <div
          v-if="item.review"
          class="order-review"
        >
          <div class="review-rate">
            Đã đánh giá: {{ item.review.star }}/5
          </div>

          <p>{{ item.review.content }}</p>
        </div>

        <div
          v-else
          class="order-review-empty"
        >
          Chỉ có thể đánh giá khi đơn hàng đã giao.
        </div>
      </article>

      <p
        v-if="!filteredOrders.length"
        class="empty"
      >
        Bạn chưa có đơn hàng nào.
      </p>
    </div>
  </section>
</template>

<script setup>
import {
  computed,
  ref
} from 'vue'

import { money } from '../utils/format'

const props = defineProps({
  orders: Array,
  currentUser: Object
})

const keyword = ref('')

const filteredOrders = computed(() =>
  props.orders.filter((item) =>
    item.user === props.currentUser?.username &&
    (
      !keyword.value ||
      item.code
        .toLowerCase()
        .includes(keyword.value.toLowerCase())
    )
  )
)

function statusClass(status) {
  if (status === 'Đã giao hàng') return 'done'
  if (status === 'Đang xử lý') return 'processing'
  if (status === 'Đang vận chuyển') return 'shipping'
  if (status === 'Chờ xác nhận') return 'waiting'

  return 'cancel'
}
</script>
