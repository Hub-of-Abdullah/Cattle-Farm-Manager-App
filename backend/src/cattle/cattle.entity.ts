import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToOne,
} from 'typeorm';
import { Owner } from '../owners/owner.entity';
import { Sale } from '../sales/sale.entity';

@Entity('cattle')
export class Cattle {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'owner_id' })
  ownerId: number;

  @ManyToOne(() => Owner, (owner) => owner.cattle, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'owner_id' })
  owner: Owner;

  @Column({ name: 'cattle_unique_id', unique: true })
  cattleUniqueId: string;

  @Column({ name: 'purchase_date', type: 'date' })
  purchaseDate: string;

  @Column({
    name: 'purchase_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: {
      to: (v: number) => v,
      from: (v: string) => parseFloat(v),
    },
  })
  purchasePrice: number;

  @Column({ name: 'is_sold', default: false })
  isSold: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToOne(() => Sale, (sale) => sale.cattle)
  sale: Sale;
}
