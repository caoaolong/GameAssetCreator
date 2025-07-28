import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/Home.vue'),
    meta: { title: '首页' }
  },
  {
    path: '/sequence-frames',
    name: 'SequenceFrames',
    component: () => import('../views/SequenceFrames.vue'),
    meta: { title: '序列帧图' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router 