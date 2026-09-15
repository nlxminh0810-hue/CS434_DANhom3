/*
  Product images are generated from the product name using a slug.
  Place image files in `src/assets/img/` with the slug name and a .jpg extension.
  Example: product name "Áo Messi phiên bản fan" -> image file: src/assets/img/ao-messi-phien-ban-fan.jpg
*/

function slugify(str) {
  return String(str)
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^a-zA-Z0-9\s-]/g, '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
}

const base = [
  { id: 1, name: 'Áo đá bóng sân nhà', category: 'Áo đấu', price: 289000, stock: 135, desc: 'Áo đấu thoáng khí, form thể thao.' },
  { id: 2, name: 'Quần thể thao cao cấp', category: 'Áo đấu', price: 219000, stock: 212, desc: 'Chất vải co giãn tốt.' },
  { id: 3, name: 'Ba lô đựng giày', category: 'Phụ kiện', price: 349000, stock: 124, desc: 'Nhiều ngăn tiện lợi.' },
  { id: 4, name: 'Bóng thi đấu cao cấp', category: 'Phụ kiện', price: 499000, stock: 245, desc: 'Độ nảy ổn định.' },
  { id: 5, name: 'Áo Messi phiên bản fan', category: 'Áo đấu', price: 399000, stock: 164, desc: 'Thiết kế nổi bật.' },
  { id: 6, name: 'Giày tốc độ sân cỏ nhân tạo', category: 'Giày bóng đá', price: 1599000, stock: 57, desc: 'Đế TF bám sân.' },
  { id: 7, name: 'Giày kiểm soát bóng', category: 'Giày bóng đá', price: 1899000, stock: 46, desc: 'Hỗ trợ chạm bóng.' },
  { id: 8, name: 'Tất chống trượt Luxury', category: 'Phụ kiện', price: 99000, stock: 96, desc: 'Đệm chân êm.' }
]

export const products = base.map(p => {
  // Use local images named img1.png..img8.png in src/assets/img/.
  // Product order follows id order, so img1 -> leftmost item, img2 -> next item, etc.
  const image = new URL(`../assets/img/img${p.id}.png`, import.meta.url).href
  return { ...p, image }
})


/*import img1 from '../assets/img/img1.jpg'
import img2 from '../assets/img/img2.jpg'
import img3 from '../assets/img/img3.jpg'
import img4 from '../assets/img/img4.jpg'
import img5 from '../assets/img/img5.jpg'
import img6 from '../assets/img/img6.jpg'
import img7 from '../assets/img/img7.jpg'
import img8 from '../assets/img/img8.jpg'

export const products = [
  {
    id: 1,
    name: 'Áo đá bóng sân nhà',
    category: 'Áo đấu',
    price: 289000,
    stock: 135,
    image: img1,
    desc: 'Áo đấu thoáng khí, form thể thao.'
  },

  {
    id: 2,
    name: 'Quần thể thao cao cấp',
    category: 'Áo đấu',
    price: 219000,
    stock: 212,
    image: img2,
    desc: 'Chất vải co giãn tốt.'
  },

  {
    id: 3,
    name: 'Ba lô đựng giày',
    category: 'Phụ kiện',
    price: 349000,
    stock: 124,
    image: img3,
    desc: 'Nhiều ngăn tiện lợi.'
  },

  {
    id: 4,
    name: 'Bóng thi đấu cao cấp',
    category: 'Phụ kiện',
    price: 499000,
    stock: 245,
    image: img4,
    desc: 'Độ nảy ổn định.'
  },

  {
    id: 5,
    name: 'Áo Messi phiên bản fan',
    category: 'Áo đấu',
    price: 399000,
    stock: 164,
    image: img5,
    desc: 'Thiết kế nổi bật.'
  },

  {
    id: 6,
    name: 'Giày tốc độ sân cỏ nhân tạo',
    category: 'Giày bóng đá',
    price: 1599000,
    stock: 57,
    image: img6,
    desc: 'Đế TF bám sân.'
  },

  {
    id: 7,
    name: 'Giày kiểm soát bóng',
    category: 'Giày bóng đá',
    price: 1899000,
    stock: 46,
    image: img7,
    desc: 'Hỗ trợ chạm bóng.'
  },

  {
    id: 8,
    name: 'Tất chống trượt Luxury',
    category: 'Phụ kiện',
    price: 99000,
    stock: 96,
    image: img8,
    desc: 'Đệm chân êm.'
  }
]*/
