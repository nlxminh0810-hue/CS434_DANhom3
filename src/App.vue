<template>
  <div>

    <AppHeader
      :page="page"
      :tabs="tabs"
      :user="currentUser"
      :cart-count="cartCount"
      @navigate="setPage"
      @login="openLogin"
      @register="openRegister"
    />

    <main class="main">

      <div class="search-area">

        <input
          v-model="keyword"
          type="search"
          placeholder="Hôm nay bạn muốn mua gì ?"
        >

        <button
          class="search-btn"
          @click="setPage('shop')"
        >
          <i class="bi bi-search"></i>
        </button>

        <button
          class="user-btn"
          @click="setPage('profile')"
        >
          <i class="bi bi-person-fill"></i>
        </button>

      </div>

      <!-- HOME -->
      <TrangChu
        v-if="page === 'home'"
        :products="products"
        @navigate="setPage"
      />

      <!-- SHOP -->
      <CuaHang
        v-else-if="page === 'shop'"
        :products="products"
        :keyword="keyword"
        @detail="openDetail"
        @cart="addCart"
      />

      <!-- DETAIL -->
      <ChiTietSanPham
        v-else-if="
          page === 'detail'
          &&
          selectedProduct
        "
        :product="selectedProduct"
        @cart="addCart"
        @buy="buyNow"
      />

      <!-- LOGIN -->
      <DangNhap
        v-else-if="page === 'login'"
        :customers="customers"
        @submit="login"
        @social="socialLogin"
        @forgot="page = 'forgot'"
        @register="openRegister"
        @navigate="setPage"
      />

      <!-- REGISTER -->
      <DangKy
        v-else-if="page === 'register'"
        @submit="register"
        @social="socialLogin"
        @login="openLogin"
        @navigate="setPage"
      />

      <!-- FORGOT -->
      <QuenMatKhau
        v-else-if="page === 'forgot'"
        @login="openLogin"
      />

      <!-- CART -->
      <GioHang
        v-else-if="page === 'cart'"
        :cart="cart"
        @remove="removeCart"
        @checkout="setPage('payment')"
      />

      <!-- PAYMENT -->
      <ThanhToan
        v-else-if="page === 'payment'"
        :cart="cart"
        :total="cartTotal"
        @confirm="confirmOrder"
      />

      <!-- ORDER -->
      <DonHang
        v-else-if="page === 'orders'"
        :orders="orders"
        :current-user="currentUser"
      />

      <!-- PROFILE -->
      <HoSo
        v-else-if="page === 'profile'"
        :profile="profile"
        @save="saveProfile"
        @logout="logout"
        @delete="deleteAccount"
      />

      <!-- ADMIN PRODUCT -->
      <QuanLySanPham
        v-else-if="
          page === 'adminProducts'
          &&
          currentUser?.role === 'admin'
        "
        :products="products"
        @add="addProduct"
        @update="updateProduct"
        @delete="deleteProduct"
        @detail="openDetail"
      />

      <!-- ADMIN USER -->
      <QuanLyNguoiDung
        v-else-if="
          page === 'adminUsers'
          &&
          currentUser?.role === 'admin'
        "
        :customers="customers"
        @delete="deleteCustomer"
      />

      <!-- REPORT -->
      <BaoCao
        v-else-if="
          page === 'reports'
          &&
          currentUser?.role === 'admin'
        "
        :orders="orders"
        :products="products"
      />

    </main>
  </div>
</template>

<script setup>
import {
  computed,
  ref
} from 'vue'

import AppHeader from './components/AppHeader.vue'

import TrangChu from './views/TrangChu.vue'
import CuaHang from './views/CuaHang.vue'
import ChiTietSanPham from './views/ChiTietSanPham.vue'

import DangNhap from './views/DangNhap.vue'
import DangKy from './views/DangKy.vue'
import QuenMatKhau from './views/QuenMatKhau.vue'

import GioHang from './views/GioHang.vue'
import ThanhToan from './views/ThanhToan.vue'

import DonHang from './views/DonHang.vue'
import HoSo from './views/HoSo.vue'

import QuanLySanPham from './views/QuanLySanPham.vue'
import QuanLyNguoiDung from './views/QuanLyNguoiDung.vue'
import BaoCao from './views/BaoCao.vue'

import {
  products as productSeed
} from './data/products'

import {
  orders as orderSeed
} from './data/orders'

import {
  customers as customerSeed
} from './data/customers'

/* =========================
   STATE
========================= */

const page = ref('home')

const keyword = ref('')

const selectedProduct = ref(null)

const currentUser = ref(null)

const products = ref([...productSeed])

const orders = ref([...orderSeed])

const customers = ref([...customerSeed])

const cart = ref([])

const profile = ref({

  name: '',

  birth: '',

  gender: '',

  email: '',

  phone: '',

  address: '',

  bio: ''
})

/* =========================
   ROLE MENU
========================= */

const tabs = computed(() => {

  // CHƯA LOGIN
  if (!currentUser.value) {

    return [

      {
        id: 'home',
        name: 'Trang chủ'
      },

      {
        id: 'shop',
        name: 'Sản phẩm'
      }

    ]
  }

  // ADMIN
  if (
    currentUser.value.role ===
    'admin'
  ) {

    return [

      {
        id: 'home',
        name: 'Trang chủ'
      },

      {
        id: 'shop',
        name: 'Sản phẩm'
      },

      {
        id: 'orders',
        name: 'Quản lý đơn hàng'
      },

      {
        id: 'adminProducts',
        name: 'QL sản phẩm'
      },

      {
        id: 'adminUsers',
        name: 'QL tài khoản'
      },

      {
        id: 'reports',
        name: 'Thống kê'
      }

    ]
  }

  // USER
  return [

    {
      id: 'home',
      name: 'Trang chủ'
    },

    {
      id: 'shop',
      name: 'Sản phẩm'
    },

    {
      id: 'orders',
      name: 'Đơn hàng'
    }

  ]
})

/* =========================
   PAGE PROTECT
========================= */

const protectedPages = [

  'cart',

  'payment',

  'profile',

  'orders',

  'adminProducts',

  'adminUsers',

  'reports'
]

/* =========================
   CART
========================= */

const cartCount = computed(() =>
  cart.value.reduce(
    (sum,item)=>
      sum + Number(item.qty || 0),
    0
  )
)

const cartTotal = computed(() =>
  cart.value.reduce(
    (sum,item)=>
      sum +
      item.price *
      Number(item.qty || 0),
    0
  )
)

/* =========================
   NAVIGATION
========================= */

function setPage(nextPage) {

  // CHƯA LOGIN
  if (
    protectedPages.includes(nextPage)
    &&
    !currentUser.value
  ) {

    page.value = 'login'

    return
  }

  // USER KHÔNG VÀO ADMIN
  if (

    [
      'adminProducts',
      'adminUsers',
      'reports'
    ].includes(nextPage)

    &&

    currentUser.value?.role !==
    'admin'

  ) {

    page.value = 'home'

    return
  }

  page.value = nextPage
}

/* =========================
   AUTH
========================= */

function openLogin() {

  page.value = 'login'
}

function openRegister() {

  page.value = 'register'
}

function login(user) {
  // `user` here is credentials emitted from the login form
  const credentials = user

  const found = customers.value.find(
    (c) => c.username === credentials.email && c.password === credentials.password
  )

  if (!found) {
    alert('Tài khoản hoặc mật khẩu không đúng.')
    page.value = 'login'
    return
  }

  if (found.locked) {
    alert('Tài khoản này đã bị khóa.')
    return
  }

  currentUser.value = { ...found }

  profile.value.name = found.name || ''
  profile.value.phone = found.phone || ''
  profile.value.email =
    found.email || (found.username && found.username.includes('@') ? found.username : `${found.username}@soccerhub.vn`)

  page.value = found.role === 'admin' ? 'adminProducts' : 'profile'
}

function register(user) {

  // MẶC ĐỊNH USER
  user.role = 'user'

  customers.value.unshift(user)

  currentUser.value = user

  profile.value.name = user.name

  profile.value.phone = user.phone

  profile.value.email =
    `${user.username}@soccerhub.vn`

  page.value = 'profile'
}

function socialLogin(provider) {

  currentUser.value = {

    username:
      provider.toLowerCase(),

    name:
      `${provider} User`,

    email:
      `${provider.toLowerCase()}@soccerhub.vn`,

    role: 'user'
  }

  profile.value.name =
    currentUser.value.name

  profile.value.email =
    currentUser.value.email

  page.value = 'profile'
}

function logout() {

  currentUser.value = null

  cart.value = []

  page.value = 'home'
}

function deleteAccount() {

  if (
    !confirm(
      'Bạn có chắc muốn xóa tài khoản?'
    )
  ) return

  logout()
}

/* =========================
   PROFILE
========================= */

function saveProfile(nextProfile) {

  profile.value = nextProfile

  currentUser.value.name =
    nextProfile.name
}

/* =========================
   PRODUCT
========================= */

function openDetail(product) {

  selectedProduct.value = product

  page.value = 'detail'
}

function addCart(

  product,

  option = {
    color: 'Xanh',
    size: 'M',
    qty: 1
  }

) {

  if (!currentUser.value) {

    page.value = 'login'

    return
  }

  const key =
    `${product.id}-${option.color}-${option.size}`

  const existed =
    cart.value.find(
      (item)=>item.key === key
    )

  if (existed) {

    existed.qty +=
      Number(option.qty || 1)

  } else {

    cart.value.push({

      ...product,

      key,

      color: option.color,

      size: option.size,

      qty:
        Number(option.qty || 1)
    })
  }
}

function buyNow(product,option) {

  addCart(product,option)

  if (currentUser.value) {

    page.value = 'payment'
  }
}

function removeCart(key) {

  cart.value =
    cart.value.filter(
      (item)=>item.key !== key
    )
}

/* =========================
   PAYMENT
========================= */

function confirmOrder(payment) {

  if (!cart.value.length) return

  const method =
    typeof payment === 'string'
      ? payment
      : payment.method

  const methodId =
    typeof payment === 'string'
      ? ''
      : payment.methodId

  const deliveryInfo =
    typeof payment === 'string'
      ? null
      : payment.delivery

  const orderTotal =
    typeof payment === 'string'
      ? cartTotal.value
      : payment.total

  const productText =
    cart.value
      .map((item) =>
        `${item.name} - ${item.qty} chiếc / ${item.color} / ${item.size}`
      )
      .join(', ')

  const deliveryNote =
    deliveryInfo
      ? `${deliveryInfo.fullName} - ${deliveryInfo.phone} - ${deliveryInfo.address}, ${deliveryInfo.ward}, ${deliveryInfo.district}, ${deliveryInfo.city}`
      : ''

  const isCod =
    methodId === 'cod' ||
    method === 'Trả tiền khi nhận hàng'

  const newOrder = {

    code:
      `SH${String(
        orders.value.length + 1
      ).padStart(3,'0')}`,

    user:
      currentUser.value.username,

    delivery:
      'Giao tiêu chuẩn',

    status:
      isCod
        ? 'Chờ xác nhận'
        : 'Đang xử lý',

    qty: cartCount.value,

    total: orderTotal,

    note:
      deliveryNote
        ? `${method} | ${deliveryNote}`
        : method,

    product: productText,

    review: null
  }

  orders.value.unshift(newOrder)

  cart.value = []

  page.value = 'orders'
}

/* =========================
   PRODUCT ADMIN
========================= */

function addProduct(product) {

  products.value.push(product)
}

function updateProduct(id,patch) {

  const index =
    products.value.findIndex(
      (item)=>item.id === id
    )

  if (index !== -1) {

    products.value[index] = {

      ...products.value[index],

      ...patch
    }
  }
}

function deleteProduct(id) {

  products.value =
    products.value.filter(
      (item)=>item.id !== id
    )
}

/* =========================
   USER ADMIN
========================= */

function deleteCustomer(id) {

  const target =
    customers.value.find(
      item => item.id === id
    )

  // KHÔNG XÓA ADMIN
  if (target?.role === 'admin') {

    alert(
      'Không thể xóa admin.'
    )

    return
  }

  customers.value =
    customers.value.filter(
      (item)=>item.id !== id
    )
}
</script>
