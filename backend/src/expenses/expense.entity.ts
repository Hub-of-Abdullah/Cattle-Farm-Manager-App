import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Owner } from '../owners/owner.entity';

export enum ExpenseCategory {
  FOOD = 'food',
  MEDICINE = 'medicine',
  DOCTOR = 'doctor',
  TAKE_PROFIT = 'takeProfit',
  OTHER = 'other',
}

@Entity('expenses')
export class Expense {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'owner_id', nullable: true })
  ownerId: number;

  @ManyToOne(() => Owner, (owner) => owner.expenses, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'owner_id' })
  owner: Owner;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'enum', enum: ExpenseCategory })
  category: ExpenseCategory;

  @Column({ name: 'custom_category', nullable: true })
  customCategory: string;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: {
      to: (v: number) => v,
      from: (v: string) => parseFloat(v),
    },
  })
  amount: number;

  @Column({ nullable: true })
  note: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
