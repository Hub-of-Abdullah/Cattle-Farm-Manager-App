import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { Cattle } from '../cattle/cattle.entity';

@Entity('sales')
export class Sale {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'cattle_id', unique: true })
  cattleId: number;

  @OneToOne(() => Cattle, (cattle) => cattle.sale, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cattle_id' })
  cattle: Cattle;

  @Column({ name: 'sale_date', type: 'date' })
  saleDate: string;

  @Column({
    name: 'sale_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: {
      to: (v: number) => v,
      from: (v: string) => parseFloat(v),
    },
  })
  salePrice: number;

  @Column({ name: 'buyer_name', nullable: true })
  buyerName: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
