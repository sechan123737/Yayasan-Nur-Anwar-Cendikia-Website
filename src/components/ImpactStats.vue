<script setup>
const stats = [
  { value: '12.500+', label: 'Siswa Teredukasi' },
  { value: '85', label: 'Sekolah Dibangun' },
  { value: '3.200+', label: 'Member Aktif' },
  { value: '24', label: 'Provinsi Tercakup' }
]
</script>

<template>
  <section id="impact" class="py-20 bg-cream scroll-mt-20">
    <div class="max-w-7xl mx-auto px-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div v-for="s in stats" :key="s.label" class="text-center p-6 bg-white rounded-2xl shadow-sm border border-green-50">
          <div class="text-3xl md:text-4xl font-display font-bold text-forest mb-1">{{ s.value }}</div>
          <p class="text-gray-500 text-sm font-medium">{{ s.label }}</p>
        </div>
      </div>
    </div>
  </section>
</template>
