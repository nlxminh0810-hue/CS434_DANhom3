<template>
  <section class="checkout-page">
    <div class="checkout-card">
      <div class="checkout-heading">
        <div class="checkout-brand">
          <i class="bi bi-dribbble"></i>
          <span>SoccerHub</span>
        </div>

        <h2>Thanh toán</h2>
      </div>

      <div class="checkout-items">
        <article
          v-for="item in cart"
          :key="item.key"
          class="checkout-item"
        >
          <img
            :src="item.image"
            :alt="item.name"
            class="checkout-item-image"
          >

          <div class="checkout-item-info">
            <h3>{{ item.name }}</h3>
            <p>{{ item.color }} / {{ item.size }}</p>

            <div class="checkout-qty">
              <button
                type="button"
                @click="decrease(item)"
              >
                -
              </button>

              <input
                v-model.number="item.qty"
                type="number"
                min="1"
                @input="normalizeQty(item)"
              >

              <button
                type="button"
                @click="increase(item)"
              >
                +
              </button>
            </div>
          </div>

          <b>{{ money(item.price * Number(item.qty || 1)) }}</b>
        </article>
      </div>

      <div class="checkout-payment">
        <div>
          <h3>Thông tin giao hàng</h3>

          <div class="delivery-grid">
            <label>
              <input
                v-model.trim="form.fullName"
                class="checkout-input"
                placeholder="Họ và tên"
              >
              <span v-if="submitted && !form.fullName">
                Vui lòng nhập họ tên
              </span>
            </label>

            <label>
              <input
                v-model.trim="form.phone"
                class="checkout-input"
                maxlength="10"
                placeholder="Số điện thoại"
                @input="digitsOnly"
              >
              <span v-if="submitted && !validPhone">
                Số điện thoại không hợp lệ
              </span>
            </label>

            <select
              v-model="form.city"
              class="checkout-input"
            >
              <option value="">Chọn thành phố</option>
              <option>Hồ Chí Minh</option>
              <option>Hà Nội</option>
              <option>Đà Nẵng</option>
            </select>

            <select
              v-model="form.district"
              class="checkout-input"
            >
              <option value="">Chọn quận</option>
              <option>Quận 1</option>
              <option>Quận 3</option>
              <option>Bình Thạnh</option>
            </select>

            <select
              v-model="form.ward"
              class="checkout-input"
            >
              <option value="">Chọn phường</option>
              <option>Phường 1</option>
              <option>Phường 5</option>
              <option>Phường 7</option>
            </select>

            <label class="delivery-address">
              <textarea
                v-model.trim="form.address"
                class="checkout-input"
                rows="4"
                placeholder="Số nhà, tên đường..."
              ></textarea>
              <span v-if="submitted && !validAddress">
                Vui lòng nhập đầy đủ địa chỉ
              </span>
            </label>
          </div>
        </div>

        <aside class="checkout-bill">
          <div class="bill-line">
            <span>Tạm tính</span>
            <b>{{ money(subtotal) }}</b>
          </div>

          <div class="bill-line">
            <span>Phí vận chuyển</span>
            <b>{{ money(shippingFee) }}</b>
          </div>

          <div class="bill-line bill-total">
            <span>Tổng cộng</span>
            <b>{{ money(grandTotal) }}</b>
          </div>

          <button
            type="button"
            class="checkout-open"
            :disabled="!cart.length"
            @click="openPayment"
          >
            <i class="bi bi-credit-card"></i>
            Thanh toán ngay
          </button>
        </aside>
      </div>
    </div>

    <div
      v-if="showModal"
      class="payment-overlay"
      @click.self="showModal = false"
    >
      <div class="payment-dialog">
        <div class="payment-dialog-head">
          <h3>Thanh toán</h3>

          <button
            type="button"
            @click="showModal = false"
          >
            <i class="bi bi-x-lg"></i>
          </button>
        </div>

        <div class="payment-dialog-body">
          <div class="payment-methods">
            <button
              v-for="method in methods"
              :key="method.id"
              type="button"
              class="payment-method"
              :class="{ active: selectedMethod.id === method.id }"
              @click="selectedMethod = method"
            >
              {{ method.name }}
            </button>
          </div>

          <div class="qr-box">
            <img
              v-if="selectedMethod.qr"
              :src="selectedMethod.qr"
              alt="Mã QR thanh toán"
            >

            <i
              v-else
              class="bi bi-cash-coin cod-icon"
            ></i>

            <h4>
              {{
                selectedMethod.qr
                  ? 'Quét mã để thanh toán'
                  : 'Thanh toán khi nhận hàng'
              }}
            </h4>

            <p>
              TÊN:
              <b>NGUYỄN THANH LONG</b>
            </p>

            <p>
              SỐ TIỀN CẦN THANH TOÁN:
              <strong>{{ money(grandTotal) }}</strong>
            </p>

            <button
              type="button"
              class="confirm-payment"
              :disabled="confirming"
              @click="confirm"
            >
              {{
                confirming
                  ? 'Đang xử lý...'
                  : 'Xác nhận thanh toán'
              }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import {
  computed,
  reactive,
  ref
} from 'vue'

import { money } from '../utils/format'

const props = defineProps({
  cart: Array,
  total: Number
})

const emit = defineEmits(['confirm'])

const shippingFee = 30000
const submitted = ref(false)
const showModal = ref(false)
const confirming = ref(false)

const form = reactive({
  fullName: '',
  phone: '',
  city: '',
  district: '',
  ward: '',
  address: ''
})

const methods = [
  {
    id: 'qr',
    name: 'QR PAY',
    qr: 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=QRPAY'
  },
  {
    id: 'momo',
    name: 'MOMO PAY',
    qr: 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=MOMOPAY'
  },
  {
    id: 'bank',
    name: 'Thanh toán ngân hàng',
    qr: 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=BANKPAY'
  },
  {
    id: 'cod',
    name: 'Trả tiền khi nhận hàng',
    qr: ''
  }
]

const selectedMethod = ref(methods[0])

const subtotal = computed(() =>
  props.cart.reduce(
    (sum,item) =>
      sum + item.price * Number(item.qty || 0),
    0
  )
)

const grandTotal = computed(() =>
  subtotal.value + shippingFee
)

const validPhone = computed(() =>
  /^\d{10}$/.test(form.phone)
)

const validAddress = computed(() =>
  Boolean(
    form.city &&
    form.district &&
    form.ward &&
    form.address
  )
)

const validForm = computed(() =>
  Boolean(
    form.fullName &&
    validPhone.value &&
    validAddress.value
  )
)

function digitsOnly() {
  form.phone = form.phone.replace(/\D/g, '')
}

function normalizeQty(item) {
  if (!Number(item.qty) || item.qty < 1) {
    item.qty = 1
  }
}

function increase(item) {
  item.qty = Number(item.qty || 1) + 1
}

function decrease(item) {
  item.qty = Math.max(
    1,
    Number(item.qty || 1) - 1
  )
}

function openPayment() {
  submitted.value = true

  if (!validForm.value) return

  showModal.value = true
}

function confirm() {
  confirming.value = true

  window.setTimeout(() => {
    emit(
      'confirm',
      {
        method: selectedMethod.value.name,
        methodId: selectedMethod.value.id,
        delivery: {
          ...form
        },
        shippingFee,
        total: grandTotal.value
      }
    )

    confirming.value = false
    showModal.value = false
  }, 600)
}
</script>
